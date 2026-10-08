#!/bin/bash
# MMG AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), cmake 3.28, g++ 13. No extra apt deps.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
AIT="$WORK/appimagetool-root/AppRun"

# 1. Clone and build (static libs/apps by default)
mkdir -p "$WORK/mmg" && cd "$WORK/mmg"
[ -d repo ] || git clone https://github.com/MmgTools/mmg repo
cd repo && git checkout 8ed2259164fa4c90be6301d247ecb1db7bd61228 && cd ..
cmake -S repo -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"
# binaries: build/bin/mmg2d_O3, build/bin/mmg3d_O3, build/bin/mmgs_O3

# 2. Assemble the AppDir (all three tools + dispatcher AppRun)
cd "$WORK"
rm -rf MMG.AppDir && mkdir -p MMG.AppDir/usr/bin
cp mmg/build/bin/mmg2d_O3 MMG.AppDir/usr/bin/mmg2d
cp mmg/build/bin/mmg3d_O3 MMG.AppDir/usr/bin/mmg3d
cp mmg/build/bin/mmgs_O3  MMG.AppDir/usr/bin/mmgs
cp github-staging/mmg/appdir/MMG.desktop github-staging/mmg/appdir/AppRun MMG.AppDir/
# (icon: generate MMG.png or reuse the staged one)
python3 - "$WORK/MMG.AppDir/MMG.png" <<'EOF'
import struct, zlib, math, sys
W=H=256; px=bytearray()
for y in range(H):
    for x in range(W):
        d=math.hypot(x-128,y-128)
        px+=bytes((40,90,160,255) if d<120 else (0,0,0,0))
raw=b''.join(b'\x00'+bytes(px[y*W*4:(y+1)*W*4]) for y in range(H))
def chunk(t,d):
    c=struct.pack('>I',len(d))+t+d
    return c+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
open(sys.argv[1],'wb').write(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',W,H,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(bytes(raw),6))+chunk(b'IEND',b''))
EOF
chmod +x MMG.AppDir/AppRun

# 3. Package
ARCH=x86_64 "$AIT" MMG.AppDir MMG-x86_64.AppImage
# -> $WORK/MMG-x86_64.AppImage
