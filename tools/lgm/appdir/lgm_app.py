#!/usr/bin/env python3
"""LGM AppImage launcher: first-run weight download + CLI passthrough to infer.py/convert.py."""
import os
import runpy
import subprocess
import sys

APPDIR = os.environ.get("APPDIR") or os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SHARE = os.path.join(APPDIR, "usr", "share", "lgm")

DATA = os.environ.get("LGM_DATA",
                       os.path.join(os.path.expanduser("~"), ".local", "share", "lgm-appimage"))
MODELS = os.path.join(DATA, "models")
os.environ["HF_HOME"] = os.path.join(DATA, "hf")
os.environ["HUGGINGFACE_HUB_CACHE"] = os.path.join(os.environ["HF_HOME"], "hub")
os.environ["TORCH_HOME"] = os.path.join(DATA, "torch")
os.environ.setdefault("PYTORCH_CUDA_ALLOC_CONF", "expandable_segments:True")
os.environ.setdefault("CUDA_MODULE_LOADING", "LAZY")
os.makedirs(MODELS, exist_ok=True)

WEIGHT_URL = "https://huggingface.co/ashawkey/LGM/resolve/main/model_fp16_fixrot.safetensors"
WEIGHT_PATH = os.path.join(MODELS, "model_fp16_fixrot.safetensors")


def ensure_weights():
    if os.path.exists(WEIGHT_PATH) and os.path.getsize(WEIGHT_PATH) > 100_000_000:
        return
    print(f"[LGM] Downloading LGM weights (~1.2GB) to {WEIGHT_PATH} ...", flush=True)
    print("[LGM] Resume supported: re-run if interrupted.", flush=True)
    subprocess.run(["curl", "-L", "-C", "-", "--retry", "5",
                    "-o", WEIGHT_PATH, WEIGHT_URL], check=True)
    print("[LGM] Weights ready.", flush=True)


def main():
    args = list(sys.argv[1:])

    if "--download-weights" in args:
        args.remove("--download-weights")
        ensure_weights()
        if not args:
            return 0

    script = "infer.py"
    if args and args[0] == "convert":
        script = "convert.py"
        args = args[1:]

    if not any(a in ("--help", "-h") for a in args):
        ensure_weights()

    if script == "infer.py" and not any(a == "--resume" or a.startswith("--resume=") for a in args):
        args = ["--resume", WEIGHT_PATH] + args

    sys.argv = [os.path.join(SHARE, script)] + args
    sys.path.insert(0, SHARE)
    runpy.run_path(os.path.join(SHARE, script), run_name="__main__")
    return 0


if __name__ == "__main__":
    sys.exit(main())
