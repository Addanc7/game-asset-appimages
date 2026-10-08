#!/bin/bash
# ArmorPaint AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), clang 18.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"

# 1. Linux build deps (per base/docs/linux_deps.md)
sudo apt-get install -y make clang libvulkan-dev libgtk-3-dev libssl-dev \
  libxi-dev libxrandr-dev libxcursor-dev libasound2-dev

# 2. Clone
mkdir -p "$WORK/armorpaint" && cd "$WORK/armorpaint"
[ -d repo ] || git clone https://github.com/armory3d/armorpaint repo
cd repo && git checkout d38a8bb659504fbfec69934a3525b1abbdd3317a && cd ..

# 3. Build with the upstream Kinc driver (generates the project, compiles with
#    clang; all assets are embedded into the binary via build/embed.h)
cd repo/paint
../base/make --compile
# -> paint/build/Release/ArmorPaint

# 4. Package (pack.sh lives at the campaign root; appimagetool extracted root
#    is expected at $WORK/appimagetool-root — see pack.sh)
cd "$WORK"
./pack.sh ArmorPaint armorpaint/repo/paint/build/Release/ArmorPaint
# -> $WORK/ArmorPaint-x86_64.AppImage
