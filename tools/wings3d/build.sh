#!/bin/bash
# build.sh — Wings3D AppImage from source (Ubuntu 24.04 / Bazzite x86-64)
# Rebuilds the Erlang app and repacks the AppDir in github-staging/wings3d/appdir.
set -e
WORK=~/workspace/build/appimage-campaign
SRC=$WORK/wings3d/src
AD=$WORK/github-staging/wings3d/appdir

# 1. Dependencies (Erlang/OTP with wxWidgets)
# sudo apt-get install -y erlang-base erlang-dev erlang-parsetools erlang-wx

# 2. Fetch source
# git clone --depth 1 https://github.com/dgud/wings "$SRC"

# 3. Build (ERL_LIBS hack: -include_lib("wings/e3d/e3d.hrl") needs a wings app dir)
# mkdir -p /tmp/wings_lib && ln -sfn "$SRC" /tmp/wings_lib/wings
# cd "$SRC" && ERL_LIBS=/tmp/wings_lib make

# 4. Assemble AppDir (see appdir/ for the reference layout):
#    - /usr/lib/erlang  <- full /usr/lib/erlang
#    - /usr/lib/wings   <- ebin plugins priv shaders textures icons license.terms
#    - /usr/bin/wings   <- launcher (bundled erl -run wings_start start_halt)
#    - AppRun, Wings3D.desktop, Wings3D.png

# 5. Pack
# cd "$WORK" && ARCH=x86_64 ./appimagetool-root/AppRun "$AD" Wings3D-x86_64.AppImage
echo "See NOTES.md; steps are documented but not re-executable blind (needs apt + source)."
