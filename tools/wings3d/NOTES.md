# Wings3D — build notes

- **Upstream repo:** https://github.com/dgud/wings
- **Git commit built:** `8ae2bfd` (master, shallow clone 2026-10-08)
- **License:** permissive BSD-style (Björn Gustavsson's `license.terms` —
  "permission to use, copy, modify, distribute, and license this software
  and its documentation for any purpose, provided that existing copyright
  notices are retained"); also `unix/COPYING`. Confirmed open-source.
- **CUDA toolkit version:** n/a — Erlang/CPU build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
Wings3D subdivision modeler (Erlang/OTP 25 + wxWidgets GUI) built from
source with `make`. The AppImage bundles the full Erlang/OTP 25.3 runtime
(`usr/lib/erlang`) plus the compiled Wings app (`usr/lib/wings`: ebin,
plugins, priv NIFs, shaders, textures, icons).

`usr/bin/wings` launches via the bundled `erl`:
`erl -noinput -smp -pa <wings ebin + plugin dirs> -run wings_start start_halt`.

## Build quirks (for reproducibility)
1. Needs Erlang/OTP with wx: `apt install erlang-base erlang-dev
   erlang-parsetools erlang-wx` (Ubuntu noble ships OTP 25.3).
2. Upstream `make` fails at `src/wings_bool.erl` with
   `record e3d_face undefined` because `-include_lib("wings/e3d/e3d.hrl")`
   cannot resolve the `wings` app. Fix: `mkdir -p /tmp/wings_lib &&
   ln -sfn <src> /tmp/wings_lib/wings` and build with
   `ERL_LIBS=/tmp/wings_lib make`. The launcher recreates this link at
   runtime under `usr/lib/wings_lib`.
3. GUI needs a display + GTK/wx libs on the host (not bundled); verified
   headless that the VM boots and all beams load.

## Verification
- `make` exit 0; `wings.beam` + `wings_start.beam` load from the AppImage
  (`APPIMAGE_EXTRACT_AND_RUN=1 Wings3D-x86_64.AppImage -noshell -eval ...`).
- wx/GTK init fails headless (no DISPLAY) — expected; GUI launch needs a
  desktop session.
