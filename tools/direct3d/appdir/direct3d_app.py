#!/usr/bin/env python3
"""Direct3D AppImage entry point.

First run downloads the model weights (one-time, resumable) into
$DIRECT3D_DATA (default ~/.local/share/direct3d-app):

  1. DreamTechAI/Direct3D: config.yaml + model.ckpt  (~7-8 GB)
  2. openai/clip-vit-large-patch14                  (~1.7 GB, HF cache)
  3. facebook/dinov2-large                          (~1.2 GB, HF cache)

Upstream VRAM guidance: 10GB @512 / 24GB @1024. On an 8GB card (RTX 4060)
the launcher defaults to fewer diffusion steps; if you still OOM, lower
--steps further or use --fp16. GPU inference needs an NVIDIA GPU + driver.
"""
import argparse
import os
import sys

APP_ROOT = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(APP_ROOT, "src")          # upstream repo copy
DATA_DIR = os.environ.get("DIRECT3D_DATA",
                          os.path.expanduser("~/.local/share/direct3d-app"))
MODELS_DIR = os.path.join(DATA_DIR, "models", "Direct3D")

HF_REPO = "DreamTechAI/Direct3D"


def ensure_models():
    from huggingface_hub import snapshot_download, hf_hub_download
    print("== Direct3D first-run setup ==")
    os.makedirs(MODELS_DIR, exist_ok=True)

    print("[1/3] Downloading DreamTechAI/Direct3D weights (resumable, one-time) ...")
    snapshot_download(repo_id=HF_REPO, local_dir=MODELS_DIR,
                      allow_patterns=["config.yaml", "model.ckpt"],
                      resume_download=True)

    print("[2/3] Downloading openai/clip-vit-large-patch14 (HF cache) ...")
    snapshot_download(repo_id="openai/clip-vit-large-patch14",
                      resume_download=True)
    print("[3/3] Downloading facebook/dinov2-large (HF cache) ...")
    snapshot_download(repo_id="facebook/dinov2-large", resume_download=True)
    print("== setup complete ==\n")


def main(argv=None):
    p = argparse.ArgumentParser(
        description="Direct3D: single image -> 3D mesh (OBJ). "
                    "First run downloads ~11GB of weights (one-time).")
    p.add_argument("input", help="Input image path.")
    p.add_argument("-o", "--output", default="direct3d_output.obj",
                   help="Output mesh path (.obj; default: direct3d_output.obj).")
    p.add_argument("--steps", type=int, default=25,
                   help="Diffusion steps (default 25; upstream default 50).")
    p.add_argument("--guidance", type=float, default=4.0)
    p.add_argument("--mc_threshold", type=float, default=-1.0,
                   help="Marching-cubes threshold (upstream example uses -1.0).")
    p.add_argument("--no_rembg", action="store_true",
                   help="Do not remove the input background.")
    p.add_argument("--skip_download", action="store_true")
    args = p.parse_args(argv)

    if not args.skip_download:
        ensure_models()

    import torch
    sys.path.insert(0, SRC_DIR)
    from direct3d.pipeline import Direct3dPipeline

    if not torch.cuda.is_available():
        print("ERROR: no NVIDIA GPU detected. Direct3D needs CUDA.")
        sys.exit(1)
    print("GPU:", torch.cuda.get_device_name(0))

    print("Loading Direct3D pipeline ...")
    pipeline = Direct3dPipeline.from_pretrained(MODELS_DIR)
    pipeline.to("cuda")
    pipeline.vae.eval(); pipeline.dit.eval()

    with torch.no_grad():
        out = pipeline(
            args.input,
            remove_background=not args.no_rembg,
            mc_threshold=args.mc_threshold,
            guidance_scale=args.guidance,
            num_inference_steps=args.steps,
        )
    mesh = out["meshes"][0]
    mesh.export(args.output)
    print("Mesh saved to", args.output)


if __name__ == "__main__":
    main()
