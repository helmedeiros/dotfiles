# vimac

[Vimac](https://github.com/nchudleigh/vimac) — Vimium-style keyboard-driven navigation of the macOS GUI. Hold `Space` to paint hint labels over every clickable element and type a label to click it; scroll-mode drives scroll areas with `hjkl`.

Complements the rest of the keyboard stack rather than replacing it: [yabai](../yabai/) + [skhd](../skhd/) move windows and spaces, [karabiner](../karabiner/) remaps keys, Vimac clicks things.

## Why this topic installs by hand

Vimac is abandonware. The author discontinued it in 2022 in favour of [Homerow](https://homerow.app), which is paid (~€39), so:

- there is no Homebrew cask (`brew search vimac` finds nothing);
- `vimacapp.com` no longer responds;
- the repo has no releases or tags, so there is nothing to download from GitHub upstream;
- the App Center link in the app's own release metadata was a signed Azure URL that expired on 2023-05-13, and App Center itself has since been retired.

The last official build — **0.3.19**, built 2021-04-24 — survives as a verbatim re-upload in the [`vimic_lives` release](https://github.com/erichmond33/vimac/releases/tag/vimic_lives) of a fork. That is the archive this topic installs.

## Why that download is trustworthy

An app that needs Accessibility access can drive the whole machine, so the binary is pinned rather than trusted. The pin was derived like this:

1. The Wayback Machine's 2023-05-12 capture of `vimacapp.com/latest-release-metadata` gives the official build's own metadata: version `0.3.19`, size `15541866` bytes, `fingerprint` (MD5) `9301624f889b079c85ca15a77c299d6d`.
2. The fork's archive has exactly that size and MD5 — it is byte-identical to the official build, not a rebuild.
3. The app inside is a universal x86_64/arm64 binary, signed with the hardened runtime by `Developer ID Application: Dexter Leng (LQ2VH8VB84)` and **notarized** (`spctl -a -t exec` → `accepted`), so Gatekeeper admits it and no quarantine dance is needed.

`install.sh` pins the archive's SHA-256 (`a03ac25e…61c4a0`) and aborts before touching `/Applications` if the download does not match, so the fork owner replacing the asset can never turn into a silent compromise.

## What `install.sh` does

- Skips immediately if `/Applications/Vimac.app` already exists (idempotent, safe under `bin/dot`).
- Downloads the pinned archive, verifies its SHA-256, and only then extracts it into `/Applications`.
- Exits `0` on a download failure so a dead link degrades to "Vimac missing" rather than breaking `bin/dot`; exits non-zero on a checksum mismatch, which is a real signal.

Overridable for testing via `VIMAC_APP`, `VIMAC_URL`, and `VIMAC_SHA256`.

## After installing

Grant Accessibility access — this cannot be scripted, macOS requires the click:

**System Settings › Privacy & Security › Accessibility** → enable **Vimac**.

Then launch Vimac and hold `Space` in any app to see hints. Preferences live in the menu bar item.

## Maintenance

The pin is deliberately frozen: 0.3.19 is the final release, so there is no upgrade path and no reason for the hash to change. If the fork's release ever disappears, the archive is identifiable anywhere by the MD5 above — no other source is required to verify a replacement copy.

The one live alternative, if Vimac eventually breaks on a future macOS, is [`mokagio/vimac`](https://github.com/mokagio/vimac): an actively maintained fork that has moved to Swift Package Manager and requires macOS 15+, but ships no prebuilt app — it needs full Xcode and a `make install` from source.

## Tests

`test/vimac/vimac_test.bats` covers the pin, the install path, checksum rejection, idempotency, and download failure, using a stubbed `curl`. Run with `test/run_tests.sh`.
