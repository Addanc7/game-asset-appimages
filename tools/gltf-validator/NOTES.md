# glTF-Validator — build notes

- **Upstream repo:** https://github.com/KhronosGroup/glTF-Validator
- **Git commit built:** `602c54043ba66856b2e68c40fdf2bced975cdb8a` (master, 2026-10-08)
- **License:** Apache-2.0 — confirmed from the repo's `LICENSE` file
  ("Apache License, Version 2.0, January 2004"). Copyright 2016-2019 The Khronos Group Inc.
- **CUDA toolkit version:** n/a — CPU/Dart build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The `gltf_validator` CLI (version 2.0.0-dev.3.11), compiled from Dart source
to a self-contained native binary with the Dart SDK's AOT compiler
(`dart compile exe bin/gltf_validator.dart`). Validates glTF 2.0 (.gltf/.glb)
assets and reports errors/warnings/infos/hints.

Usage: `gltf_validator model.glb`

## Build quirks
- The repo is pre-null-safety Dart (`sdk: '>=2.11.99 <3.0.0'`), so Dart 2.19.6
  (not Dart 3.x) must be used to compile it. The Dart SDK is the compiler/
  runtime here (like node in the campaign rules) — the tool itself is compiled
  from the repo's Dart source.
- `dart pub get` dependency resolution hung (pub.dev API fetch retries), so
  the 10 transitive packages (args, isolate, meta, path, vector_math, yaml,
  collection, source_span, string_scanner, term_glyph) were downloaded as
  source tarballs from pub.dev and wired via a hand-written
  `repo/.dart_tool/package_config.json`. Dev-dependencies were excluded
  (not needed to compile the CLI). The repo's `pubspec.yaml` was restored
  afterwards.
