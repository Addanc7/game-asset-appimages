#!/bin/bash
# gltf-transform AppImage build script — reproducible from a clean checkout.
# Tested on the campaign build VM (x86-64), node v24.20.0, npm 10.9.4.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
T="$WORK/gltf-transform"
REPO="$T/repo"
GT_APPDIR_BIN="$T/Gltf-Transform.AppDir"

# 1. Clone
mkdir -p "$T" && cd "$T"
[ -d repo ] || git clone https://github.com/donmccurdy/glTF-Transform repo
cd repo && git checkout 3797aad585021e68cf5fbf3f2fba37783596ffac && cd ..

# 2. Install runtime deps for the CLI workspace subtree only (docs workspace
#    excluded: it has an unresolvable svelte peer conflict upstream)
cd repo
npm install --legacy-peer-deps --omit=dev --no-audit --no-fund \
  --workspace=@gltf-transform/cli --workspace=@gltf-transform/core \
  --workspace=@gltf-transform/extensions --workspace=@gltf-transform/functions
npm install --legacy-peer-deps --no-audit --no-fund --no-save tsdown typescript

# 3. Build the TypeScript packages from source, in dependency order
export PATH="$PWD/node_modules/.bin:$PATH"
for p in core extensions functions cli; do
  npm run build -w "@gltf-transform/$p"
done

# 4. Prune dev-only packages
npm prune --omit=dev --legacy-peer-deps \
  --workspace=@gltf-transform/cli --workspace=@gltf-transform/core \
  --workspace=@gltf-transform/extensions --workspace=@gltf-transform/functions
cd ..

# 5. Stage the AppDir and package.
#    The exact staging (node runtime + built packages + icon + .desktop +
#    AppRun passthrough) is in $T/mkappdir.sh, which also runs appimagetool.
"$T/mkappdir.sh"
# -> $WORK/Gltf-Transform-x86_64.AppImage
# (appimagetool extracted root expected at $WORK/appimagetool-root — see mkappdir.sh)
