#!/bin/bash
# glTF-Validator AppImage build script — reproducible from a clean checkout.
# Tested on the campaign build VM (x86-64).
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
T="$WORK/gltf-validator"

# 1. Clone
mkdir -p "$T" && cd "$T"
[ -d repo ] || git clone https://github.com/KhronosGroup/glTF-Validator repo
cd repo && git checkout 602c54043ba66856b2e68c40fdf2bced975cdb8a && cd ..

# 2. Dart SDK 2.19.6 (compiler/runtime; repo is pre-null-safety, needs Dart 2.x)
#    https://storage.googleapis.com/dart-archive/channels/stable/release/2.19.6/sdk/dartsdk-linux-x64-release.zip
DART="$T/dartsdk2/dart-sdk/bin"
export PATH="$DART:$PATH"

# 3. Dependencies: `dart pub get` in this repo hangs on pub.dev API retries,
#    so vendor the 10 needed packages as source tarballs from pub.dev and
#    write repo/.dart_tool/package_config.json by hand (see NOTES.md).
#    Packages: args, isolate, meta, path, vector_math, yaml, collection,
#    source_span, string_scanner, term_glyph (+ the root `gltf` package itself).

# 4. Compile the CLI from Dart source to a native binary
cd repo
dart compile exe bin/gltf_validator.dart -o ../gltf_validator
cd ..

# 5. Package (pack.sh lives at the campaign root; appimagetool extracted root
#    is expected at $WORK/appimagetool-root — see pack.sh)
cd "$WORK"
./pack.sh Gltf-Validator gltf-validator/gltf_validator
# -> $WORK/Gltf-Validator-x86_64.AppImage
