#!/usr/bin/env python3
"""Unique3D AppImage entry point.

Single image -> textured 3D mesh (GLB), using the upstream inference code
(app/gradio_3dgen.generate3dv2 flow, without Gradio).

First run downloads the model weights (one-time, resumable) into
$UNIQUE3D_DATA (default ~/.local/share/unique3d-app):

  1. ckpt/* from the Wuvin/Unique3D Hugging Face Space
     (image2normal, img2mvimg, controlnet-tile, realesrgan-x4.onnx, ~7 GB)
  2. runwayml/stable-diffusion-v1-5 (HF cache; only if --refine)
  3. h94/IP-Adapter image encoder   (HF cache; only if --refine)

The upstream demo refines with an SD1.5 ControlNet pipeline; on an 8GB card
(RTX 4060) the launcher defaults to --no_refine for safety. Pass --refine
to enable it. GPU inference needs an NVIDIA GPU + driver.
"""
import argparse
import os
import shutil
import sys

APP_ROOT = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(APP_ROOT, "src")              # upstream repo copy
DATA_DIR = os.environ.get("UNIQUE3D_DATA",
                          os.path.expanduser("~/.local/share/unique3d-app"))
MODELS_DIR = os.path.join(DATA_DIR, "models")
CKPT_DIR = os.path.join(MODELS_DIR, "ckpt")
WORK_DIR = os.path.join(DATA_DIR, "work")


def ensure_models(with_refine):
    from huggingface_hub import snapshot_download
    print("== Unique3D first-run setup ==")
    os.makedirs(MODELS_DIR, exist_ok=True)
    ckpt_marker = os.path.join(CKPT_DIR, "realesrgan-x4.onnx")
    if not os.path.exists(ckpt_marker):
        print("  downloading ckpt/* from Wuvin/Unique3D Space (resumable, one-time) ...")
        snapshot_download(repo_id="Wuvin/Unique3D", repo_type="space",
                          allow_patterns=["ckpt/*"], local_dir=MODELS_DIR,
                          resume_download=True)
    else:
        print("  ckpt/ already present.")
    if with_refine:
        print("  downloading runwayml/stable-diffusion-v1-5 (HF cache) ...")
        snapshot_download(repo_id="runwayml/stable-diffusion-v1-5",
                          resume_download=True)
        print("  downloading h94/IP-Adapter image encoder (HF cache) ...")
        snapshot_download(repo_id="h94/IP-Adapter", resume_download=True)
    print("== setup complete ==\n")


def prepare_workdir():
    """CWD with symlinks: upstream code uses relative ckpt/ + app/ paths."""
    os.makedirs(WORK_DIR, exist_ok=True)
    for name in ("app", "scripts", "mesh_reconstruction", "custum_3d_diffusion"):
        link = os.path.join(WORK_DIR, name)
        target = os.path.join(SRC_DIR, name)
        if os.path.islink(link) or os.path.exists(link):
            continue
        os.symlink(target, link)
    ckpt_link = os.path.join(WORK_DIR, "ckpt")
    if not (os.path.islink(ckpt_link) or os.path.exists(ckpt_link)):
        os.symlink(CKPT_DIR, ckpt_link)
    os.chdir(WORK_DIR)


def main(argv=None):
    p = argparse.ArgumentParser(
        description="Unique3D: single image -> textured 3D mesh (GLB). "
                    "First run downloads ~7GB of weights (one-time).")
    p.add_argument("input", help="Input image path.")
    p.add_argument("-o", "--output", default="unique3d_output.glb",
                   help="Output mesh path (.glb; default: unique3d_output.glb).")
    p.add_argument("--seed", type=int, default=-1)
    p.add_argument("--refine", action="store_true",
                   help="Enable SD1.5 ControlNet detail refinement (heavier, needs ~+4GB weights).")
    p.add_argument("--expansion_weight", type=float, default=0.1)
    p.add_argument("--init_type", default="std", choices=["std", "thin"])
    p.add_argument("--skip_download", action="store_true")
    args = p.parse_args(argv)

    if not args.skip_download:
        ensure_models(with_refine=args.refine)
    prepare_workdir()

    import torch
    torch.set_float32_matmul_precision("medium")
    torch.backends.cuda.matmul.allow_tf32 = True
    torch.set_grad_enabled(False)
    sys.path.insert(0, SRC_DIR)

    if not torch.cuda.is_available():
        print("ERROR: no NVIDIA GPU detected. Unique3D needs CUDA.")
        sys.exit(1)
    print("GPU:", torch.cuda.get_device_name(0))

    from PIL import Image
    from pytorch3d.structures import Meshes
    from app.custom_models.mvimg_prediction import run_mvprediction
    from scripts.refine_lr_to_sr import run_sr_fast
    from scripts.multiview_inference import geo_reconstruct
    from scripts.utils import save_glb_and_video

    preview_img = Image.open(args.input).convert("RGBA")
    if preview_img.size[0] <= 512:
        print("Upscaling input with RealESRGAN ...")
        preview_img = run_sr_fast([preview_img])[0]

    print("Predicting multiview images ...")
    rgb_pils, front_pil = run_mvprediction(preview_img, remove_bg=True,
                                           seed=int(args.seed))

    print("Reconstructing geometry ...")
    new_meshes = geo_reconstruct(rgb_pils, None, front_pil,
                                 do_refine=args.refine, predict_normal=True,
                                 expansion_weight=args.expansion_weight,
                                 init_type=args.init_type)

    vertices = new_meshes.verts_packed()
    vertices = vertices / 2 * 1.35
    vertices[..., [0, 2]] = -vertices[..., [0, 2]]
    new_meshes = Meshes(verts=[vertices], faces=new_meshes.faces_list(),
                        textures=new_meshes.textures)

    tmp_prefix = os.path.join(WORK_DIR, "unique3d_out")
    ret_mesh, _ = save_glb_and_video(tmp_prefix, new_meshes,
                                     with_timestamp=False, export_video=False)
    out = os.path.abspath(args.output)
    os.makedirs(os.path.dirname(out) or ".", exist_ok=True)
    shutil.move(ret_mesh, out)
    print("Mesh saved to", out)


if __name__ == "__main__":
    main()
