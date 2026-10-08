#!/usr/bin/env python3
"""CraftsMan3D single-image inference CLI: image -> 3D mesh (via CraftsManPipeline)."""
import argparse
import os
import sys

import torch

SHARE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SHARE)


def main():
    p = argparse.ArgumentParser(description="CraftsMan3D: single image to 3D mesh")
    p.add_argument("--input", required=True, help="input image (png/jpg)")
    p.add_argument("--output", required=True, help="output mesh (.obj/.glb)")
    p.add_argument("--ckpt", required=True, help="CraftsMan checkpoint dir")
    p.add_argument("--steps", type=int, default=50, help="denoising steps (default 50)")
    p.add_argument("--guidance", type=float, default=7.5, help="guidance scale")
    p.add_argument("--seed", type=int, default=None)
    p.add_argument("--mc_depth", type=int, default=8, help="marching cubes depth")
    p.add_argument("--device", default="cuda" if torch.cuda.is_available() else "cpu")
    args = p.parse_args()

    from craftsman import CraftsManPipeline
    print(f"[CraftsMan3D] Loading pipeline from {args.ckpt} ...", flush=True)
    pipeline = CraftsManPipeline.from_pretrained(
        args.ckpt, device=args.device, torch_dtype=torch.bfloat16)
    print(f"[CraftsMan3D] Generating mesh for {args.input} ...", flush=True)
    out = pipeline(args.input, num_inference_steps=args.steps,
                   guidance_scale=args.guidance, seed=args.seed,
                   mc_depth=args.mc_depth)
    mesh = out.meshes[0]
    mesh.export(args.output)
    print(f"[CraftsMan3D] Wrote {args.output}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
