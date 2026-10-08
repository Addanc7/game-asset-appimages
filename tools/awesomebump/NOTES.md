# AwesomeBump — build notes

- **Upstream repo:** https://github.com/kmkolasinski/AwesomeBump
- **Git commit built:** `f9fad16e066e366636dad05cb4c53c9e0aa2d729` (master, 2026-10-08)
  plus the QtnProperty submodule at `0fed3e829bcec8b5656030e547e4955f89e33b80`
- **License:** GPL-3.0 — confirmed from the repo's `LICENSE.txt`
  ("GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007").
- **CUDA toolkit version:** n/a — CPU/Qt build (OpenGL rendering)
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged

The `awesomebump` Qt5 GUI binary, compiled from source with cmake + g++.
The upstream CMakeLists was stale/broken; `build.sh` applies a build-system-only
patch (embedded in the script): include dirs for the QtnProperty unity build,
Qt5Script find+link, `-DVERSION_STRING="5.1"` (from the qmake .pro), a fix for
the source-list-clobbering `set()` bug, source globs replacing the stale file
list, AUTOMOC coverage for QtnProperty headers, and compilation of the
QtnPEG-generated `.peg.cpp` files. No application code was changed.

The AppImage carries the binary, the `Bin/` resources (`Core/`, `Configs/`)
side-by-side (the build uses `-DRESOURCE_BASE=.`, resolved relative to cwd —
the AppRun `cd`s into `usr/bin` first), the bundled Qt5/X11 libraries, the
upstream icon, and a GUI `.desktop` entry.

Usage: `./AwesomeBump-x86_64.AppImage`
