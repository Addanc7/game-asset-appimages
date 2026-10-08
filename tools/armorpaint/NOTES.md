# ArmorPaint — build notes

- **Upstream repo:** https://github.com/armory3d/armorpaint
- **Git commit built:** `d38a8bb659504fbfec69934a3525b1abbdd3317a` (main, 2026-10-08; v1.0 line)
- **License:** zlib/libpng — confirmed from the repo's `license.md`
  ("The zlib/libpng License ... Permission is granted to anyone to use this
  software for any purpose, including commercial applications ...").
- **CUDA toolkit version:** n/a — CPU/C++ build (Kinc/Iron, Vulkan renderer)
- **VRAM expectations:** n/a (GPU painting app; needs a Vulkan-capable GPU at runtime)
- **First-run weight download:** none — no weights

## What is packaged

`paint/build/Release/ArmorPaint`, built from source with the upstream Kinc
build driver (`paint/../base/make --compile`, which generates the project and
invokes clang). All assets are embedded into the binary at build time
(`build/embed.h`), so the AppImage carries just the binary plus its shared
library dependencies (X11, Vulkan loader, GTK3, OpenSSL, ALSA, ...).
