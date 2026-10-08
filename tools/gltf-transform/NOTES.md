# gltf-transform — build notes

- **Upstream repo:** https://github.com/donmccurdy/glTF-Transform
- **Git commit built:** `3797aad585021e68cf5fbf3f2fba37783596ffac` (master, 2026-10-08)
- **License:** MIT — confirmed from the repo's `LICENSE.md`
  ("The MIT License (MIT)", Copyright (c) 2024 Don McCurdy)
- **CUDA toolkit version:** n/a — CPU/Node.js build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The `@gltf-transform/cli` 4.5.1 command-line interface, compiled from
TypeScript source with tsdown (packages `core`, `extensions`, `functions`,
`cli` built in dependency order), bundled with the Node.js v24.20.0 runtime
binary (runtime, like a compiler — the tool itself is built from source via
`npm install` + per-package `npm run build` + `npm prune --omit=dev` on the
cloned repo). Third-party runtime deps only; docs/devDeps excluded (the docs
workspace has an unresolvable svelte peer conflict upstream — worked around
with `--legacy-peer-deps` + per-workspace installs, docs workspace excluded).

Usage: `gltf-transform copy in.glb out.glb`, plus `inspect`, `optimize`,
`merge`, `draco`, `etc1s`/`uastc`, `weld`, `dedup`, … (full CLI in `--help`)
