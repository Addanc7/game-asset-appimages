# gltfpack-x86_64.AppImage

Portable AppImage of **gltfpack 1.3** (the glTF/GLB optimizer from the
[meshoptimizer](https://github.com/zeux/meshoptimizer) project, MIT license),
built from source with cmake + g++ on 2026-10-07. No GPU, no model weights,
no network — pure C++ CLI, runs anywhere x86-64 Linux.

- AppImage: `gltfpack-x86_64.AppImage` (1.3 MB)
- git commit: `4195af679a7e4a968b4a23874272f152600c9f72` (2026-10-07)
- Toolchain: g++ 13.3.0, cmake 3.28.3, Release build
- Linked: libm + libc only (libstdc++/libgcc statically linked), so it runs
  on Bazzite / Fedora 44+ userspace without extra deps.

Make it executable and run it from anywhere:

```sh
chmod +x gltfpack-x86_64.AppImage
./gltfpack-x86_64.AppImage -h        # full help
./gltfpack-x86_64.AppImage -v        # prints "gltfpack 1.3"
```

## Example commands

```sh
# 1. Basic optimize: input GLB -> optimized GLB
./gltfpack-x86_64.AppImage -i model.glb -o model_opt.glb

# 2. Mesh-compressed output (EXT_meshopt_compression, big size win)
./gltfpack-x86_64.AppImage -i model.glb -o model_opt.glb -cc

# 3. OBJ -> optimized GLB (gltfpack also reads .obj and .gltf)
./gltfpack-x86_64.AppImage -i model.obj -o model.glb

# 4. Simplify to ~50% of triangles while optimizing
./gltfpack-x86_64.AppImage -i model.glb -o model_simple.glb -si 0.5

# 5. Aggressive: simplify + meshopt compression + 10-bit position quantization
./gltfpack-x86_64.AppImage -i model.glb -o model_tiny.glb -cc -si 0.25 -vp 10

# 6. Force vertex colors / normals as needed
./gltfpack-x86_64.AppImage -i model.glb -o model_n.glb -vn 8 -vnf
```

Flag cheatsheet (from `-h`):

| Flag | Meaning |
|------|---------|
| `-c` / `-cc` / `-cz` | compressed output (quantization / meshopt / both) |
| `-si R` | simplify meshes to ratio R of triangles (e.g. 0.5) |
| `-sa` | aggressive simplification (may change topology) |
| `-vp N` / `-vt N` / `-vn N` | N-bit quantization for positions / texcoords / normals |
| `-tc` / `-tu` | KTX2/BasisU texture compression (needs BasisU build; NOT enabled in this AppImage) |
| `-ke` | keep extras, `-kn` keep node names, `-km` keep material names |
| `-noq` | disable quantization |

Notes:
- This build does **not** include BasisU texture compression (`-tc`/`-tu`
  require the basisu encoder linked at compile time and were left out to keep
  the AppImage tiny and dependency-free). Mesh/texture transforms, vertex
  quantization, simplification and meshopt compression all work.
- FUSE note: on systems without FUSE, run `./gltfpack-x86_64.AppImage --appimage-extract`
  and use `squashfs-root/AppRun` instead.

## Rebuild from source

```sh
git clone https://github.com/zeux/meshoptimizer.git
cd meshoptimizer
cmake -S . -B build -DMESHOPT_BUILD_GLTFPACK=ON -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc"
cmake --build build -j$(nproc)
./build/gltfpack -v   # -> gltfpack 1.3
```

Then copy `build/gltfpack` into `AppDir/usr/bin/` and run
`appimagetool.AppImage AppDir gltfpack-x86_64.AppImage`.
