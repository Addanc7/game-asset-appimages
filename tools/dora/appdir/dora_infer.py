#!/usr/bin/env python3
"""Dora-VAE single-mesh inference: mesh -> shape latents -> reconstructed mesh.

Thin CLI over the Dora (Seed3D) MichelangeloAutoencoder: encodes an input mesh
into Dora-VAE latents and decodes it back to a mesh via marching cubes.
Useful as a mesh compression / VAE round-trip demo.
"""
import argparse
import os
import sys

import numpy as np
import torch
import trimesh
import yaml

SHARE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SHARE)


def load_model(ckpt_path, device):
    from craftsman.models.autoencoders.michelangelo_autoencoder import MichelangeloAutoencoder
    cfg_path = os.path.join(SHARE, "configs", "shape-autoencoder", "Dora-VAE-test.yaml")
    with open(cfg_path) as f:
        cfg = yaml.safe_load(f)
    model_cfg = cfg["system"]["shape_model"]
    # drop the checkpoint path entry; we load weights manually
    model_cfg = {k: v for k, v in model_cfg.items() if k != "pretrained_model_name_or_path"}
    model = MichelangeloAutoencoder(**model_cfg)
    print(f"[Dora] Loading checkpoint {ckpt_path} ...", flush=True)
    ckpt = torch.load(ckpt_path, map_location="cpu")
    state = ckpt.get("state_dict", ckpt)
    # strip possible "shape_model." prefix from lightning checkpoints
    state = {k.replace("shape_model.", ""): v for k, v in state.items()}
    missing, unexpected = model.load_state_dict(state, strict=False)
    print(f"[Dora] missing={len(missing)} unexpected={len(unexpected)}", flush=True)
    model = model.to(device).eval()
    return model


def sample_surface(mesh, n_points):
    # normalize to [-0.95, 0.95]
    v = mesh.vertices - (mesh.vertices.min(0) + mesh.vertices.max(0)) / 2
    scale = np.abs(v).max()
    v = v / scale * 0.95
    mesh = trimesh.Trimesh(vertices=v, faces=mesh.faces, process=False)
    points, face_idx = trimesh.sample.sample_surface(mesh, n_points)
    normals = mesh.face_normals[face_idx]
    return np.concatenate([points, normals], axis=1).astype(np.float32)


def main():
    p = argparse.ArgumentParser(description="Dora-VAE mesh round-trip: encode -> decode a mesh")
    p.add_argument("--input", required=True, help="input mesh (.obj/.ply/.stl)")
    p.add_argument("--output", required=True, help="output reconstructed mesh (.obj)")
    p.add_argument("--ckpt", required=True, help="Dora-VAE checkpoint (.ckpt)")
    p.add_argument("--points", type=int, default=32768, help="surface samples (default 32768)")
    p.add_argument("--octree_depth", type=int, default=8, help="marching-cubes grid depth (default 8)")
    p.add_argument("--device", default="cuda" if torch.cuda.is_available() else "cpu")
    args = p.parse_args()

    device = torch.device(args.device)
    mesh = trimesh.load(args.input, process=True, force="mesh")
    print(f"[Dora] Input: {args.input} ({len(mesh.vertices)} verts)", flush=True)

    surf = sample_surface(mesh, args.points)
    # coarse + sharp surfaces (uniform split; sharp-edge sampling is optional upstream)
    half = args.points // 2
    coarse = torch.from_numpy(surf[:half]).unsqueeze(0).to(device)
    sharp = torch.from_numpy(surf[half:half * 2]).unsqueeze(0).to(device)

    model = load_model(args.ckpt, device)
    with torch.no_grad():
        shape_latents, kl_embed, posterior = model.encode(coarse, sharp, sample_posterior=False)
        latents = model.decode(kl_embed)
        print(f"[Dora] Latents: {tuple(latents.shape)}", flush=True)
        mesh_v_f, has_surface = model.extract_geometry(latents, octree_depth=args.octree_depth)

    if not has_surface[0]:
        print("[Dora] ERROR: no surface extracted", flush=True)
        return 1
    verts, faces = mesh_v_f[0]
    out = trimesh.Trimesh(vertices=verts, faces=faces, process=False)
    out.export(args.output)
    print(f"[Dora] Wrote {args.output} ({len(verts)} verts, {len(faces)} faces)", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
