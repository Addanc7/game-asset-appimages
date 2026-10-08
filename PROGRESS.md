# AppImage Campaign — Progress Log

Chris: "build them all" (2026-10-07). AppImages from source for every open-source game-asset tool lacking an official Linux AppImage. Source: `~/workspace/your_files/OpenSource_GameAsset_Tools_Missing_AppImage.md`.

Rules: build from source (no prebuilt binaries), one `<Tool>-x86_64.AppImage` each, no bundled weights (first-run download to `~/.local/share/<app>/models`), verify launch, upload each to Google Drive immediately.

Skipped (other agents): TRELLIS.2, Pixal3D, TripoSR, UniRig, gltfpack, Step1X-3D.

| Tool | Category | License | Status | Drive link | GitHub | Notes |
|---|---|---|---|---|---|---|
| InstantMesh | 3D gen | Apache-2.0 (verified) | building | | | |
| Unique3D | 3D gen | MIT (verified) | building | | | |
| Hi3DGen | 3D gen | MIT (reported) | building | | | verify license |
| Direct3D | 3D gen | MIT (reported) | building | | | verify license |
| LGM | 3D gen | MIT | building | | | custom CUDA kernels |
| Era3D | 3D gen | AGPL-3.0 | building | | | |
| SyncDreamer | 3D gen | MIT (likely) | building | | | verify license |
| Dora | 3D gen | Apache-2.0 (reported) | building | | | shape VAE component only; verify license |
| CraftsMan3D | 3D gen | MIT vs AGPL-3.0 conflict | building | | | verify LICENSE file; build if either confirmed |
| Wonder3D | 3D gen | MIT vs AGPL-3.0 conflict | building | | | verify LICENSE file; build if either confirmed |
| Michelangelo | 3D gen | unverified (GPL-3.0 fork claim) | building | | | verify; skip if unconfirmable |
| CLAY/OpenCLAY | 3D gen | unconfirmed | building | | | verify; skip if unconfirmable |
| Manifold | mesh | Apache-2.0 | done | https://drive.google.com/file/d/1b9LxkpHQuvpMxhZpJkBxO5NsThNhJH4t/view?usp=drivesdk | committed | convertFile CLI as `manifold`; license verified from LICENSE |
| Instant Meshes | mesh | BSD-3-Clause | done | https://drive.google.com/file/d/1oXFCvIU64QXvYASupnzEYldgV2FnVnH0/view?usp=drivesdk | committed | batch mode headless-verified; license verified from LICENSE.txt |
| QuadriFlow | mesh | BSD-3-Clause | done | https://drive.google.com/file/d/1cJZJze7gv4KabmlDBxNZ52Zjov5yNXuk/view?usp=drivesdk | committed | license verified from LICENSE.txt |
| MeshFix | mesh | GPL-3.0+ dual | done | https://drive.google.com/file/d/10LaBqUfRT0F4jb6n6n4mEorTIO9mqL78/view?usp=drivesdk | committed | GPL-3.0 terms used; verified from gpl-3.0.txt |
| MMG | mesh | LGPL-3.0 | done | https://drive.google.com/file/d/1imrzHVsk2GYbo7HUT4w-UNtSHqOlduhz/view?usp=drivesdk | committed | mmg2d+mmg3d+mmgs via dispatcher AppRun; license verified from LICENSE |
| TetWild | mesh | GPL-3.0 | queued | | | |
| fTetWild | mesh | MPL-2.0 | queued | | | |
| Wings3D | mesh | BSD (likely) | queued | | | needs Erlang runtime; may be infeasible |
| xatlas | UV | MIT | queued | | | library + example CLI; package the example CLI |
| Thekla atlas | UV | MIT | queued | | | |
| Material Maker | material | MIT | queued | | | Godot project; export via Godot (Godot binary = compiler, allowed) |
| ArmorPaint | material | zlib/libpng | queued | | | build via Kinc/clang |
| AwesomeBump | material | GPL-3.0 | queued | | | Qt build; dormant |
| gltf-transform | converter | MIT | queued | | | npm CLI; wrap node+package |
| FBX2glTF | converter | BSD-3-Clause | queued | | | prefer ufbx SDK-free fork (weg901127/fbx2.1glb); verify its license |
| obj2gltf | converter | Apache-2.0 | queued | | | npm CLI; wrap node+package |
| assimp | converter | BSD-3-Clause | queued | | | cmake; package `assimp` CLI |
| KTX-Software/toktx | converter | Apache-2.0 | queued | | | cmake |
| OpenCOLLADA | converter | MIT | queued | | | |
| glTF-Validator | converter | Apache-2.0 | queued | | | check stack (npm/TS) |
| Meshroom/AliceVision | photogrammetry | MPL-2.0 | queued | | | big C++ build, CUDA for depth maps |
| COLMAP | photogrammetry | BSD-3-Clause | queued | | | cmake |
| openMVS | photogrammetry | AGPL-3.0 | queued | | | heavy build |
| MicMac | photogrammetry | CECILL-B | queued | | | big suite |
| Blender | DCC | GPL | deferred | | | official portable tarball exists; decide later whether source build is worth it |
| TRELLIS (OG) | 3D gen | MIT (reported) | skipped | | | already have `~/workspace/build/trellis-appimage/TRELLIS-x86_64.AppImage` |
| Hunyuan3D 2.x | 3D gen | Tencent restricted | skipped | | | not open-source (territory exclusion) |
| Stable Fast 3D | 3D gen | Stability restricted | skipped | | | not open-source ($1M revenue cap) |
| SPAR3D | 3D gen | Stability restricted | skipped | | | not open-source |
| SAM 3D | 3D gen | Meta custom | skipped | | | not open-source |
| Zero123/XL | 3D gen | none found | skipped | | | no license = not open-source |
| CRM | 3D gen | unknown | skipped | | | license unknown, cannot confirm open-source |
| One-2-3-45 | 3D gen | unknown | skipped | | | license unknown, cannot confirm open-source |
| GRM | 3D gen | unreleased | skipped | | | "coming soon" README, nothing to build |
| trimesh | mesh | MIT | skipped | | | pip library, not a standalone program |
| Open3D | mesh | MIT | skipped | | | library, not a standalone program |
| ptex | UV | BSD-3-Clause | skipped | | | library, not a standalone program |
| NormalMap-Online | material | MIT | skipped | | | web app, zero-install already |
| Materialize | material | GPL-3.0 | skipped | | | Windows-only (Unity C#), no Linux port |
| Rigify | rigging | GPL-3.0 | skipped | | | Blender-bundled addon |
| mGear | rigging | MIT | skipped | | | Maya plugin (proprietary host) |
| BlenRig | rigging | GPL | skipped | | | Blender addon |
| mmpose | rigging | Apache-2.0 | skipped | | | pip library |
| usd_from_gltf | converter | Apache-2.0 | skipped | | | repo archived 2023 |
| OpenDroneMap | photogrammetry | AGPL-3.0 | skipped | | | docker-first by design; native source build infeasible |
| OpenMVG | photogrammetry | MPL-2.0 | skipped | | | library, not a standalone program |
| Regard3D | photogrammetry | MIT | skipped | | | dormant since 2019 |
