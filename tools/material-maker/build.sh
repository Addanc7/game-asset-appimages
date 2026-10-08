#!/bin/bash
# Material Maker AppImage build script — reproducible from a clean checkout.
# Material Maker is a Godot (GDScript) project: the "build" is an editor export
# of the project's own source. The Godot editor binary acts as the compiler
# (documented exception in the campaign rules); no prebuilt app binaries are
# repackaged. Tested on Ubuntu 24.04 (x86-64), Godot 4.7.2.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
GODOT_VER=4.7.2

# 1. Clone the project source
mkdir -p "$WORK/material-maker" && cd "$WORK/material-maker"
[ -d repo ] || git clone https://github.com/RodZill4/material-maker repo
cd repo && git checkout 174f15edece663bf10f78588840873fa2fd17bc7 && cd ..

# 2. Get the Godot editor (compiler) + export templates
mkdir -p godot && cd godot
[ -f Godot_v${GODOT_VER}-stable_linux.x86_64.zip ] || \
  wget -q https://github.com/godotengine/godot/releases/download/${GODOT_VER}-stable/Godot_v${GODOT_VER}-stable_linux.x86_64.zip
[ -f Godot_v${GODOT_VER}-stable_export_templates.tpz ] || \
  wget -q https://github.com/godotengine/godot/releases/download/${GODOT_VER}-stable/Godot_v${GODOT_VER}-stable_export_templates.tpz
unzip -o -q Godot_v${GODOT_VER}-stable_linux.x86_64.zip
chmod +x Godot_v${GODOT_VER}-stable_linux.x86_64
cd ..
GODOT="$WORK/material-maker/godot/Godot_v${GODOT_VER}-stable_linux.x86_64"

# 3. Install export templates where the editor expects them
TPLDIR="$HOME/.local/share/godot/export_templates/${GODOT_VER}.stable"
mkdir -p "$TPLDIR"
unzip -o -q godot/Godot_v${GODOT_VER}-stable_export_templates.tpz -d "$TPLDIR"
[ -f "$TPLDIR/linux_release.x86_64" ] || { mv "$TPLDIR"/templates/* "$TPLDIR"/ && rmdir "$TPLDIR"/templates; }

# 4. Import the project, then export the Linux/X11 release preset from source
"$GODOT" --headless --path repo --import
"$GODOT" --headless --path repo --export-release "Linux/X11" "$WORK/material-maker/material_maker.x86_64"
# binary lands at repo/material_maker.x86_64 (Godot resolves the output path
# relative to the project); move it next to the build dir
mv repo/material_maker.x86_64 material_maker.x86_64

# 5. Assemble the AppDir (binary is self-contained: embed_pck=true)
APPDIR="$WORK/Material-Maker.AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib"
cp material_maker.x86_64 "$APPDIR/usr/bin/material-maker"
cp repo/icon.png "$APPDIR/Material-Maker.png"
cat > "$APPDIR/Material-Maker.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Material Maker
Comment=Procedural PBR material authoring tool
Exec=material-maker
Icon=Material-Maker
Terminal=false
Categories=Graphics;3DGraphics;
EOF
cat > "$APPDIR/AppRun" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib:$LD_LIBRARY_PATH"
export PATH="$HERE/usr/bin:$PATH"
exec "$HERE/usr/bin/material-maker" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# 6. Build the AppImage (appimagetool extracted root expected at
#    $WORK/appimagetool-root — see campaign pack.sh)
cd "$WORK"
ARCH=x86_64 ./appimagetool-root/AppRun Material-Maker.AppDir Material-Maker-x86_64.AppImage
# -> $WORK/Material-Maker-x86_64.AppImage
