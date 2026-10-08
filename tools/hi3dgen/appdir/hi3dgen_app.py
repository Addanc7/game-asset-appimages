#!/usr/bin/env python3
"""Hi3DGen AppImage entry point.

Geometry-only image-to-3D. First run downloads the model weights
(one-time, resumable) into $HI3DGEN_DATA (default ~/.local/share/hi3dgen-app):

  1. Stable-X/trellis-normal-v0-1  - Hi3DGen geometry pipeline
  2. Stable-X/yoso-normal-v1-8-1   - YOSO normal-estimation pipeline (StableNormal turbo)
  3. ZhengPeng7/BiRefNet           - foreground masking (HF cache)

Upstream needs ~12GB VRAM. On an 8GB card (RTX 4060) the launcher defaults
to smaller resolutions and fewer steps; geometry quality will be lower and
an OOM is still possible on complex inputs. GPU inference needs NVIDIA GPU.
"""
import argparse
import os
import sys

APP_ROOT = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(APP_ROOT, "src")              # upstream Hi3DGen repo
STN_DIR = os.path.join(APP_ROOT, "stn-src")          # StableNormal repo (Apache-2.0)
DATA_DIR = os.environ.get("HI3DGEN_DATA",
                          os.path.expanduser("~/.local/share/hi3dgen-app"))
MODELS_DIR = os.path.join(DATA_DIR, "models")

TRELLIS_NORMAL_DIR = os.path.join(MODELS_DIR, "trellis-normal-v0-1")
YOSO_DIR = os.path.join(MODELS_DIR, "yoso-normal-v1-8-1")


def ensure_models():
    from huggingface_hub import snapshot_download
    print("== Hi3DGen first-run setup ==")
    os.makedirs(MODELS_DIR, exist_ok=True)
    jobs = [
        ("Stable-X/trellis-normal-v0-1", TRELLIS_NORMAL_DIR),
        ("Stable-X/yoso-normal-v1-8-1", YOSO_DIR),
    ]
    for repo_id, local_dir in jobs:
        if os.path.isdir(local_dir) and os.listdir(local_dir):
            print(f"  already present: {repo_id}")
            continue
        print(f"  downloading {repo_id} (resumable, one-time) ...")
        snapshot_download(repo_id=repo_id, local_dir=local_dir,
                          resume_download=True)
    print("  downloading ZhengPeng7/BiRefNet (HF cache) ...")
    snapshot_download(repo_id="ZhengPeng7/BiRefNet", resume_download=True)
    print("== setup complete ==\n")


def main(argv=None):
    p = argparse.ArgumentParser(
        description="Hi3DGen: single image -> 3D geometry mesh. "
                    "First run downloads ~10GB of weights (one-time).")
    p.add_argument("input", help="Input image path.")
    p.add_argument("-o", "--output", default="hi3dgen_output.glb",
                   help="Output mesh path (.glb/.obj; default: hi3dgen_output.glb).")
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--resolution", type=int, default=768,
                   help="Input processing resolution (default 768; upstream 1024).")
    p.add_argument("--ss_steps", type=int, default=25,
                   help="Sparse-structure sampling steps (default 25; upstream 50).")
    p.add_argument("--slat_steps", type=int, default=6,
                   help="Structured-latent sampling steps (default 6).")
    p.add_argument("--normal_steps", type=int, default=10,
                   help="Normal-predictor diffusion steps (default 10).")
    p.add_argument("--skip_download", action="store_true")
    args = p.parse_args(argv)

    if not args.skip_download:
        ensure_models()

    os.environ.setdefault("SPCONV_ALGO", "native")
    import torch
    from PIL import Image
    sys.path.insert(0, SRC_DIR)
    sys.path.insert(0, STN_DIR)
    from hi3dgen.pipelines import Hi3DGenPipeline
    from hubconf import StableNormal_turbo  # torch.hub entrypoint, local source

    if not torch.cuda.is_available():
        print("ERROR: no NVIDIA GPU detected. Hi3DGen needs CUDA.")
        sys.exit(1)
    print("GPU:", torch.cuda.get_device_name(0))

    print("Loading Hi3DGen geometry pipeline ...")
    hi3dgen_pipeline = Hi3DGenPipeline.from_pretrained(TRELLIS_NORMAL_DIR)
    hi3dgen_pipeline.cuda()

    print("Loading StableNormal-turbo normal predictor ...")
    normal_predictor = StableNormal_turbo(
        local_cache_dir=MODELS_DIR, device="cuda:0",
        yoso_version="yoso-normal-v1-8-1")

    image = Image.open(args.input).convert("RGBA")
    image = hi3dgen_pipeline.preprocess_image(image, resolution=args.resolution)
    print("Estimating normals ...")
    normal_image = normal_predictor(
        image, resolution=768, match_input_resolution=True,
        data_type="object", num_inference_steps=args.normal_steps)

    print("Generating geometry ...")
    outputs = hi3dgen_pipeline.run(
        normal_image,
        seed=args.seed,
        formats=["mesh"],
        preprocess_image=False,
        sparse_structure_sampler_params={"steps": args.ss_steps,
                                         "cfg_strength": 3.0},
        slat_sampler_params={"steps": args.slat_steps,
                             "cfg_strength": 3.0},
    )
    mesh = outputs["mesh"][0].to_trimesh(transform_pose=True)
    mesh.export(args.output)
    print("Mesh saved to", args.output)


if __name__ == "__main__":
    main()
