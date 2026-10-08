#!/bin/bash
# xatlas AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"

# 1. Clone
mkdir -p "$WORK/xatlas" && cd "$WORK/xatlas"
[ -d repo ] || git clone https://github.com/jpcy/xatlas repo
cd repo && git checkout f700c7790aaa030e794b52ba7791a05c085faf0c && cd ..

# 2. Compile the example CLI from source (translation units taken from the
#    upstream premake5 "example" project)
mkdir -p build && cd build
g++ -O2 -std=c++11 -DNDEBUG \
  -I ../repo/source/xatlas -I ../repo/source/thirdparty \
  ../repo/source/xatlas/xatlas.cpp \
  ../repo/source/thirdparty/tiny_obj_loader.cpp \
  ../repo/source/thirdparty/stb_image_write.c \
  ../repo/source/examples/example.cpp \
  -o xatlas-example -lpthread
cp xatlas-example ../xatlas
cd ..

# 3. Smoke test
./build/xatlas-example repo/models/gazebo.obj | tail -2

# 4. Package (pack.sh lives at the campaign root; appimagetool extracted root
#    is expected at $WORK/appimagetool-root — see pack.sh)
cd "$WORK"
./pack.sh Xatlas xatlas/xatlas
# -> $WORK/Xatlas-x86_64.AppImage
