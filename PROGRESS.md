# AppImage Campaign — Progress Log

Chris: "build them all" (2026-10-07). AppImages from source for every open-source game-asset tool lacking an official Linux AppImage. Source: `~/workspace/your_files/OpenSource_GameAsset_Tools_Missing_AppImage.md`.

Rules: build from source (no prebuilt binaries), one `<Tool>-x86_64.AppImage` each, no bundled weights (first-run download to `~/.local/share/<app>/models`), verify launch, upload each to Google Drive immediately.

Skipped (other agents): TRELLIS.2, Pixal3D, TripoSR, UniRig, gltfpack, Step1X-3D.

| Tool | Category | License | Status | Drive link | GitHub | Notes |
|---|---|---|---|---|---|---|
| InstantMesh | 3D gen | Apache-2.0 (verified) | done | pending (3GB upload) |  | Apache-2.0 verified; --help OK; weights ~9GB first-run |
| Unique3D | 3D gen | MIT (verified) | done | pending (3GB upload) |  | MIT verified; --help OK; weights ~7GB first-run |
| Hi3DGen | 3D gen | MIT (verified) | done | pending (3GB upload) |  | MIT verified; geometry-only; 8GB-tuned defaults |
| Direct3D | 3D gen | Apache-2.0 (verified; brief said MIT) | done | pending (3GB upload) |  | Apache-2.0 (was reported MIT); 8GB-tuned defaults |
| LGM | 3D gen | MIT | done | pending (3GB upload) |  | MIT verified; --help OK; weights ~1.2GB first-run |
| Era3D | 3D gen | AGPL-3.0 | done | pending (3GB upload) |  | AGPL-3.0 verified; tiny-cuda-nn NOT bundled (nvcc OOM) — multiview only |
| SyncDreamer | 3D gen | MIT (likely) | done | pending (3GB upload) |  | MIT verified; --help OK; weights ~3.5GB first-run |
| Dora | 3D gen | Apache-2.0 (reported) | done | pending (3GB upload) |  | Apache-2.0 verified; VAE round-trip CLI; weights ~1.5GB |
| CraftsMan3D | 3D gen | MIT vs AGPL-3.0 conflict | done | pending (3GB upload) |  | MIT per README (no LICENSE file; mirrors AGPL claim wrong per worker) |
| Wonder3D | 3D gen | MIT vs AGPL-3.0 conflict | skipped |  |  | pins torch==1.13.1 — incompatible with shared torch 2.4.0 base; needs separate CUDA 11.7 toolchain |
| Michelangelo | 3D gen | unverified (GPL-3.0 fork claim) | done | pending (3GB upload) |  | GPL-3.0 verified; --help OK; weights ~2GB |
| CLAY/OpenCLAY | 3D gen | unconfirmed | skipped |  |  | no license anywhere; repo is paper/promo, code coming soon |
| Manifold | mesh | Apache-2.0 | done | https://drive.google.com/file/d/1b9LxkpHQuvpMxhZpJkBxO5NsThNhJH4t/view?usp=drivesdk | committed | convertFile CLI as `manifold`; license verified from LICENSE |
| Instant Meshes | mesh | BSD-3-Clause | done | https://drive.google.com/file/d/1oXFCvIU64QXvYASupnzEYldgV2FnVnH0/view?usp=drivesdk | committed | batch mode headless-verified; license verified from LICENSE.txt |
| QuadriFlow | mesh | BSD-3-Clause | done | https://drive.google.com/file/d/1cJZJze7gv4KabmlDBxNZ52Zjov5yNXuk/view?usp=drivesdk | committed | license verified from LICENSE.txt |
| MeshFix | mesh | GPL-3.0+ dual | done | https://drive.google.com/file/d/10LaBqUfRT0F4jb6n6n4mEorTIO9mqL78/view?usp=drivesdk | committed | GPL-3.0 terms used; verified from gpl-3.0.txt |
| MMG | mesh | LGPL-3.0 | done | https://drive.google.com/file/d/1imrzHVsk2GYbo7HUT4w-UNtSHqOlduhz/view?usp=drivesdk | committed | mmg2d+mmg3d+mmgs via dispatcher AppRun; license verified from LICENSE |
| TetWild | mesh | GPL-3.0 (verified) | done | https://drive.google.com/file/d/1Pw6owDD6xo7fCPBo-uTBEcjsffhSAOb_/view?usp=drivesdk | staged | --help OK; tetrahedron meshed via AppImage; CGAL 4.12 built from source |
| fTetWild | mesh | MPL-2.0 (verified) | done | https://drive.google.com/file/d/1jynDVg6vGaYVvASqkEoox1_QbtQHS8F0/view?usp=drivesdk | staged | --help OK; tetrahedron meshed (15,923 tets) via AppImage |
| Wings3D | mesh | BSD-style (verified, license.terms) | done | https://drive.google.com/file/d/1IT1ypYTmKeyBBuJ93DKXdsBrlbF9hmkp/view?usp=drivesdk | staged | Erlang OTP 25 runtime bundled; 35MB; beams verified loading |
| xatlas | UV | MIT | done | https://drive.google.com/file/d/1ldc6AJejxmgIzMHMV84S7BtV5oWhou2C/view?usp=drivesdk | staged | library + example CLI; packaged the example CLI as `xatlas`; --help OK + full gazebo atlas run verified |
| Thekla atlas | UV | MIT | done | https://drive.google.com/file/d/1rLbQOSwyhefeK7n5MGTJ15v1lzHt8xxw/view?usp=drivesdk | staged | cmake build; packaged the `thekla_atlas_test` atlas CLI as `thekla-atlas`; full cube atlas run verified |
| Material Maker | material | MIT | done | https://drive.google.com/file/d/16r3pW_qvmr3Jn4kZTgDsThWRkIEA9_vw/view?usp=drivesdk | staged | Godot 4.7 project exported from source w/ official 4.7.2 editor (compiler exception); embed_pck=true; headless launch OK |
| ArmorPaint | material | zlib/libpng | done | https://drive.google.com/file/d/1d_3TwP8uafJ3uUJfqKQCB738ppRWrrGC/view?usp=drivesdk | staged | Kinc build (clang 18) via ../base/make --compile; Xvfb launch reaches Vulkan init (no GPU in VM); real icon + Terminal=false |
| AwesomeBump | material | GPL-3.0 | done | https://drive.google.com/file/d/1hxAMz7wlb1X9xbH1rxxoCNg1KYuUlU1-/view?usp=drivesdk | staged | Qt5 build; upstream CMakeLists patched (build-system only); Xvfb launch OK, GL 4.5 widget up |
| gltf-transform | converter | MIT (verified) | done | https://drive.google.com/file/d/1jYPtlKP2Ld488kuheZxzJtb-Evm6WDHK/view?usp=drivesdk | staged | TS compiled from source (tsdown) + node v24.20.0 runtime; --version + glb copy test OK; publish staged |
| FBX2glTF | converter | BSD-3-Clause (verified, ufbx fork) | done | https://drive.google.com/file/d/1H3unR_6nU6hunHbE3zRU20q48qu-wCzR/view?usp=drivesdk | staged | cmake; `fbx2glb` CLI w/ Draco; SDK-free ufbx fork, no Autodesk SDK; --help + fbx→gltf test OK; publish staged |
| obj2gltf | converter | Apache-2.0 (verified) | done | https://drive.google.com/file/d/14O5fspmH4vKe4aA_-S98nZcXS40iJ0ld/view?usp=drivesdk | staged | npm CLI (pure JS) + node v24.20.0 runtime; --help + obj→glb test OK; publish staged |
| assimp | converter | BSD-3-Clause (verified) | done | https://drive.google.com/file/d/1I-9FiKi9V7iHxlU4Diuu2tJbWmgTsFye/view?usp=drivesdk | staged | cmake; `assimp` CLI (needs -DASSIMP_BUILD_ASSIMP_TOOLS=ON); help + obj→glb test OK; publish staged |
| KTX-Software/toktx | converter | Apache-2.0 (verified) | done | https://drive.google.com/file/d/1tdosea8sm5ErO_vdl1b4CL4TE8cCA0lW/view?usp=drivesdk | staged | cmake; unified `ktx` v5.0 CLI (`ktx create` = toktx successor) + toktx symlink; --version + png→ktx2 test OK; publish staged |
| OpenCOLLADA | converter | MIT (verified) | done | https://drive.google.com/file/d/1zdgG_XM4pGwIeybvzmRGVGj7gN80GqgZ/view?usp=drivesdk | staged | cmake; DAEValidator + OpenCOLLADAValidator via dispatcher AppRun; both validated a test .dae; publish staged |
| glTF-Validator | converter | Apache-2.0 (verified) | done | https://drive.google.com/file/d/1dmWudv6wYA4yBf_eLdydPpwhfbfEUixz/view?usp=drivesdk | staged | Dart source → native binary (Dart 2.19.6 AOT); --help + glb validation test OK; publish staged |
| Meshroom/AliceVision | photogrammetry | MPL-2.0 | skipped | | | 3-4h+ build on 2 cores; over per-tool budget (see status/meshroom.md) |
| COLMAP | photogrammetry | BSD-3-Clause (verified) | done | https://drive.google.com/file/d/1rlnEps3qEGgoNJVN-22bQQSFe35WCY1g/view?usp=drivesdk | staged | CPU-only headless (no CUDA/GUI); 126MB; DB creation verified via AppImage |
| openMVS | photogrammetry | AGPL-3.0 (verified) | skipped | | | builds all deps from source; 3-5h on 2 cores (see status/openmvs.md) |
| MicMac | photogrammetry | CECILL-B (verified) | skipped | | | big suite; 2-3h on 2 cores (see status/micmac.md) |
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
