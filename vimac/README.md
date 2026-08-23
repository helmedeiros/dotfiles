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

Frozen also means **it can never be fixed**. Its Sparkle updater points at `api.appcenter.ms`, and App Center was retired in March 2025, so the feed is dead — harmless (the domain is Microsoft's, not lapsable), but no future release can ever arrive through it. Whatever macOS breaks next, this binary stays broken.

## Where this is heading

The 0.3.19 binary **works on macOS 26** — verified by use, not assumption (`hintModeActivationCount` in `dexterleng.vimac` prefs, no crash reports). So it stays the daily driver: notarized, stable Accessibility grant, zero friction.

The succession plan is a private pair of repos, not a bet on someone else's hosting:

| Repo | Source | Role |
| --- | --- | --- |
| `helmedeiros/vimac-archive` | `nchudleigh/vimac` | Frozen original, 912 commits — insurance against upstream disappearing |
| `helmedeiros/vimac-next` | `mokagio/vimac` | Working copy — SPM, macOS 15+, builds and tests green on Xcode 26 |

`vimac-next` is cloned at `~/Code/active/vimac-next` with `upstream` pointing at `mokagio/vimac`. It builds a `com.mokacoding.vimac-dev` bundle, deliberately a different id from the installed 0.3.19, so both coexist and experimenting cannot break the working install.

Switch this topic from hash-pinned download to build-from-source once the dev build has proven itself in daily use. Until then, the pinned binary is the one that must keep working.

### On signing — solved, at no cost

macOS keys the Accessibility grant to a binary's *designated requirement*. Ad-hoc signing puts the per-build cdhash in it, so every rebuild reads as a different app and the grant is lost. A stable certificate replaces that with

```
identifier "com.mokacoding.vimac-dev" and certificate root = H"b5e2f5f9…"
```

which is byte-identical across rebuilds — verified by building, editing a source file, rebuilding, and diffing. **Grant Accessibility to Vimac Dev once and it stays granted.**

The identity is `Vimac Local Dev`: a self-signed code-signing certificate in the login keychain, trusted for code signing. Free — no Apple Developer subscription. It is machine-local, so recreate it on a new machine (`openssl req -x509` with `extendedKeyUsage=codeSigning`, import, then trust it in Keychain Access); without it the build falls back to ad-hoc, which still works.

`~/Code/active/vimac-next/Config/Project.local.xcconfig` selects it. That file is gitignored, and the `baseConfigurationReference` that loads it is a repo-relative path, so it affects **only that project, only that clone** — nothing else you build is signed with this identity.

`scripts/build.sh` resolves signing as environment → that xcconfig → ad-hoc, and enforces the result on the xcodebuild command line, because the project pins `CODE_SIGN_IDENTITY` at target level and only the command line outranks that. Fixed upstream-side in `vimac-next` (`aa7351e`, `6c3b593`).

Rejected alternatives, recorded so the trade-off is not re-argued later:

- **Apple Developer Program** — $99/year, and buying it solely to keep an Accessibility grant costs more every year than Homerow costs once.
- **Homerow** — €39 one-time, the maintained commercial successor. Declined on price.

## Tests

`test/vimac/vimac_test.bats` covers the pin, the install path, checksum rejection, idempotency, and download failure, using a stubbed `curl`. Run with `test/run_tests.sh`.
