# Chunked AppImages — how to download and reassemble

The big AppImages in this folder (2.6–3.9 GB each) are split into ~400 MB chunks
(`<Name>.part-00`, `<Name>.part-01`, …) because single uploads that large are
unreliable. **You need ALL chunks for a tool to rebuild it.**

## Quick start

1. Download **every** `.part-*` file for the tool you want, plus `reassemble.sh`,
   into one empty folder.
2. Run:
   ```bash
   chmod +x reassemble.sh
   ./reassemble.sh <Name>.AppImage
   ```
   Example: `./reassemble.sh UniRig-x86_64.AppImage`
3. The script concatenates the parts in order, checks the total size, and makes
   the AppImage executable. Then just run it:
   ```bash
   ./UniRig-x86_64.AppImage
   ```

## Manual method (no script)

```bash
cat <Name>.AppImage.part-* | sort -V > <Name>.AppImage   # careful: shell glob order
chmod +x <Name>.AppImage
```
Using `reassemble.sh` is safer — it sorts numerically (`part-09` before `part-10`).

## Verify integrity (optional)

Compare against the SHA256 manifest below:

```bash
sha256sum <Name>.AppImage
```

## What's here

| Tool | AppImage | Size | Chunks | SHA256 |
|---|---|---|---|---|
| UniRig | UniRig-x86_64.AppImage | 3.9 GB | 10 | ddd95bea55c3ca1ae505a998023b616d7d6ceac3b58699098c4fe2e82a55349b |
| TripoSR | TripoSR-x86_64.AppImage | 2.9 GB | 7 | 6dd309bdffe2611e18fabf546ca1552ea32a97bb2fa85ca0cc2c3f1aaa98553d |
| Step1X-3D | Step1X-3D-x86_64.AppImage | 3.4 GB | 9 | ffc6bd532c3982cf4b22b8c3d39672a84537ec1a2e67b65965d038a9ff54c2b5 |
| InstantMesh | InstantMesh-x86_64.AppImage | 2.9 GB | 7 | d9d11f6d92a6b8ccf817fae0623019c348142c457d45de4c4526886633f45782 |
| Unique3D | Unique3D-x86_64.AppImage | 3.2 GB | 8 | c431e5bd5e8707bd8355a5efef27280e22d6d0a6951d572f75bb4869a2d6c63e |
| Hi3DGen | Hi3DGen-x86_64.AppImage | 2.9 GB | 7 | 1296be196632c9117eb701bd20e32d5be0e0b8fe39a590be020ae325890bde53 |
| Direct3D | Direct3D-x86_64.AppImage | 2.9 GB | 7 | 47eb585038aa94ae60d715664017b2987043ca4364d488cf3acfebe667b43c8b |
| LGM | LGM-x86_64.AppImage | 3.2 GB | 8 | a19bae96cddc8735e27758621d562f491a63f958986ba35b0dfb6769595787af |
| Era3D | Era3D-x86_64.AppImage | 3.3 GB | 8 | 18a4309ca9cfe2853eb02de87bc9d3a5a59215f00085258339eb2d8c6c4e94c5 |
| SyncDreamer | SyncDreamer-x86_64.AppImage | 3.7 GB | 9 | 2188d912e7a29dcc05cf9d3d5531544e0a502194ed57d5ee86138b0febf35725 |
| Dora | Dora-x86_64.AppImage | 3.3 GB | 8 | 949e3a1d30a396fc54b237c71001413666ae112501f456353a85e2b95126536b |
| CraftsMan3D | CraftsMan3D-x86_64.AppImage | 3.3 GB | 8 | 210add56e8c6b31a6191a69d3d1d17058e48b1f6b9e643bab27bf025f58af6f4 |
| Michelangelo | Michelangelo-x86_64.AppImage | 3.2 GB | 8 | 74ea162e12b9f4fcb78f25589b18d0c1473d2309ab78538980447266f80c73df |

## Notes

- First launch of each AppImage downloads its model weights (1–16 GB depending
  on the tool) to `~/.local/share/<app>/models`. Let it finish.
- All AppImages were built from upstream source. Build recipes live at
  https://github.com/Addanc7/game-asset-appimages under `tools/<name>/`.
- These are free, keep them free.
