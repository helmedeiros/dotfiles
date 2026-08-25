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

Two sources, and the machine's current state decides which applies:

| Situation | What happens |
| --- | --- |
| Something is already at `/Applications/Vimac.app` | Left alone. The script reports *which* build it is and exits `0`. |
| Nothing installed | Downloads **your own published build** from `helmedeiros/vimac-next` releases, verifies its signature, installs it. |
| Nothing installed, own build unavailable | Falls back to the pinned 0.3.19 archive, verified by SHA-256. |
| `VIMAC_BUILD_FROM_SOURCE=1` | Clones the private repo if needed, builds Release, installs that. |

So a fresh machine gets **your** Vimac, not the 2021 binary — without needing Xcode, a checkout, or a build. The pinned archive is the last resort for when the private release cannot be reached (no `gh`, not authenticated, no network).

**An existing install is never replaced.** The script identifies what is there by **bundle id**, not by the path — both sources land on the same `Vimac.app`, and only the identifier distinguishes them:

- `com.mokacoding.vimac` → self-built
- `dexterleng.vimac` → the pinned 0.3.19
- anything else → third-party, still left alone

That distinction is the point. A path check alone would let `bin/dot` quietly reinstall the 2021 binary over a build you deliberately chose to run — the exact regression `test/vimac/vimac_test.bats` now guards.

Building is **opt-in, never automatic**: it needs Xcode and takes minutes, which has no place in every `bin/dot` run. A missing checkout or missing Xcode prints what to do and exits `0` rather than breaking the run. A dead download link does the same; only a checksum mismatch exits non-zero, because that is a real signal rather than an absence.

```sh
VIMAC_BUILD_FROM_SOURCE=1 vimac/install.sh    # clone if needed, build, install
VIMAC_PREFER_OWN_BUILD=0  vimac/install.sh    # skip your build, use the pinned 0.3.19
```

### Two artefacts, two ways to verify

| Artefact | Verified by | Why |
| --- | --- | --- |
| Pinned 0.3.19 | Archive **SHA-256** | Frozen forever, so one hash covers it permanently |
| Your own build | Signing **certificate** | A hash would need re-pinning on every release; the certificate does not change |

The certificate check is not cosmetic: the download is refused unless the app's designated requirement is `identifier "com.mokacoding.vimac" and certificate root = H"b5e2f5f9…"`, followed by a `codesign --verify --strict`. Tested by pointing it at a deliberately wrong certificate — it refuses and falls back to the pinned binary rather than installing something unverified. Regenerating the signing identity means updating `VIMAC_OWN_CERT_SHA1`.

### Publishing a new build

The download path needs a release to exist. After changing the app:

```sh
cd ~/Code/active/vimac-next && make install          # build Release + install locally
ditto -c -k --sequesterRsrc --keepParent \
  build/Build/Products/Release/Vimac.app /tmp/Vimac.zip
gh release create vX.Y.Z-helmed /tmp/Vimac.zip --repo helmedeiros/vimac-next
```

`install.sh` fetches the latest release, so other machines pick it up on their next `bin/dot`.

Overridable via `VIMAC_APP`, `VIMAC_SOURCE_DIR`, `VIMAC_SOURCE_REPO`, `VIMAC_URL`, `VIMAC_SHA256`, `VIMAC_OWN_CERT_SHA1`.

## After installing

Grant Accessibility access — this cannot be scripted, macOS requires the click:

**System Settings › Privacy & Security › Accessibility** → enable **Vimac**.

Then launch Vimac and hold `Space` in any app to see hints. Preferences live in the menu bar item.

Note that the two builds have **different bundle ids**, so macOS treats them as different apps: switching between them needs a fresh Accessibility grant, and `UserDefaults` preferences do not carry over (the key *names* match, so values can be copied across by hand).

## Maintenance

The pin is deliberately frozen: 0.3.19 is the final release, so there is no upgrade path and no reason for the hash to change. If the fork's release ever disappears, the archive is identifiable anywhere by the MD5 above — no other source is required to verify a replacement copy.

Frozen also means **it can never be fixed**. Its Sparkle updater points at `api.appcenter.ms`, and App Center was retired in March 2025, so the feed is dead — harmless (the domain is Microsoft's, not lapsable), but no future release can ever arrive through it. Whatever macOS breaks next, this binary stays broken.

## Current state

**The self-built 0.4.0 is the installed and running app** (`com.mokacoding.vimac`, signed `Vimac Local Dev`), published as [`v0.4.0-helmed`](https://github.com/helmedeiros/vimac-next/releases/tag/v0.4.0-helmed) so other machines can install the same binary without building it. The pinned 0.3.19 is now purely the last-resort fallback.

Rolling back is two commands — the pinned archive is still reachable and hash-verified, so the restore is exact:

```sh
sudo rm -rf /Applications/Vimac.app
vimac/install.sh
```

## How this got here

The 0.3.19 binary **does work on macOS 26** — verified by use, not assumption (`hintModeActivationCount` in its prefs, no crash reports). It served as the daily driver while the replacement was proven, which is why the pin still exists rather than having been deleted.

The succession is a private pair of repos, not a bet on someone else's hosting:

| Repo | Source | Role |
| --- | --- | --- |
| `helmedeiros/vimac-archive` | `nchudleigh/vimac` | Frozen original, 912 commits — insurance against upstream disappearing |
| `helmedeiros/vimac-next` | `mokagio/vimac` | Working copy — SPM, macOS 15+, builds and tests green on Xcode 26 |

`vimac-next` is cloned at `~/Code/active/vimac-next` with `upstream` pointing at `mokagio/vimac`. Debug builds (`make build`, `make run`) carry a `-dev` bundle-id suffix so they coexist with whatever is installed — experimenting cannot break the working copy. `make install` builds Release under the plain id and replaces `/Applications/Vimac.app`.

### Security review

Audited before granting Accessibility, which is keylogger-grade permission. Across 8,699 lines of Swift:

- **No network code at all** — no `URLSession`, sockets, or `WKWebView`. Every `http://` in the source is a comment or a GitHub link opened in the browser by an explicit menu click. Sparkle is gone, so unlike 0.3.19 there is no updater and no phone-home.
- **No process execution, no dynamic code loading, no run-script build phases, no CI workflows, no encoded blobs.**
- **Three dependencies**, pinned by commit and checked against upstream tags: RxSwift 5.1.1, AXSwift 0.3.2, MASShortcut — all canonical repos, all matching.
- **Genuine fork**: `git merge-base --is-ancestor` confirms the original is a true ancestor; authorship is the original author plus the fork maintainer.
- The two `CGEvent` taps see every keystroke — unavoidable for a global hotkey — but compare against the configured activation key and pass everything else through unchanged. Nothing accumulated, logged, or persisted beyond 17 preference keys.

One hazard found, and it is operational rather than malicious: `scripts/install.sh` in that repo does `rm -rf /Applications/Vimac.app`. That is the intended upgrade path, but it means `make install` replaces whatever is there.

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

`test/vimac/vimac_test.bats` (11 tests, stubbed `curl`, no network) covers the checksum pin and its provenance, the install path, checksum rejection, idempotency, and download failure — plus the source-detection rules that matter most:

- a self-built install is never replaced by the pinned binary;
- the pinned binary is recognised and left alone;
- an unrecognised third-party app at that path is left alone rather than clobbered;
- building from source is opt-in, and a missing checkout does not break `bin/dot`.

Run with `test/run_tests.sh`.
