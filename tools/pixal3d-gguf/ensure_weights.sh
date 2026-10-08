#!/bin/bash
# Shared first-run weight downloader for the TRELLIS.2-GGUF / Pixal3D-GGUF AppImages.
# Usage: ensure_weights.sh <models_dir> <base_url> <file1> <file2> ...
# Downloads with resume (curl -C -) and skips files already present at the
# expected size.
set -u
MODELS_DIR="$1"; BASE_URL="$2"; shift 2
mkdir -p "$MODELS_DIR"
fail=0
for spec in "$@"; do
  name="${spec%%|*}"; size="${spec##*|}"
  out="$MODELS_DIR/$name"
  if [ -f "$out" ] && [ "$(stat -c%s "$out")" = "$size" ]; then
    echo "[weights] $name already present (${size} bytes), skipping"
    continue
  fi
  echo "[weights] downloading $name ..."
  if ! curl -fL --retry 3 --retry-delay 5 -C - -o "$out" "$BASE_URL/$name"; then
    echo "[weights] FAILED to download $name" >&2
    fail=1
  fi
done
if [ "$fail" != "0" ]; then
  echo "[weights] one or more weight downloads failed; delete partial files in $MODELS_DIR and re-run" >&2
  exit 1
fi
echo "[weights] all model files present in $MODELS_DIR"
