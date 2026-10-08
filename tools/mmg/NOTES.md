# MMG — build notes

- **Upstream repo:** https://github.com/MmgTools/mmg
- **Git commit built:** `8ed2259164fa4c90be6301d247ecb1db7bd61228` (master, 2026-10-07)
- **License:** LGPL-3.0 — confirmed from the repo's `LICENSE` file
  ("mmg is free software … under the terms of the GNU Lesser General Public
  License … either version 3 of the License, or (at your option) any later
  version."; see also `COPYING.LESSER`)
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
MMG 5.8.0 anisotropic remeshing suite — all three CLIs (`mmg2d`, `mmg3d`,
`mmgs`) in one AppImage. Binaries are statically linked (only libc/libm), so
the AppDir ships no extra libraries. The AppRun is a dispatcher: the tool is
selected as the first argument.

Usage: `MMG-x86_64.AppImage {mmg2d|mmg3d|mmgs} [options] input.mesh [output]`
