#!/bin/sh
#
# Vimac — keyboard-driven navigation of the macOS GUI (hint-mode, scroll-mode).
#
# Two sources, and which one you get depends on what the machine already has:
#
#   1. Built from source out of the private `vimac-next` checkout. This is the
#      one to run: maintained upstream, auditable, and signed by a local
#      identity so the Accessibility grant survives rebuilds. Opt in with
#      VIMAC_BUILD_FROM_SOURCE=1 — it is not the default because it needs Xcode
#      and takes minutes, which does not belong in every `bin/dot` run.
#
#   2. The hash-pinned 0.3.19 binary. Vimac was discontinued in 2022: there is
#      no Homebrew cask, vimacapp.com is offline, and the App Center download in
#      its release metadata expired on 2023-05-13. The last official build
#      survives only as a verbatim re-upload in a fork's GitHub release, so it
#      is pinned by hash rather than trusted by host. This is the bootstrap
#      fallback: no Xcode, no checkout, works on a fresh machine.
#
# VIMAC_SHA256 is the checksum of the archive whose MD5 equals the `fingerprint`
# in vimacapp.com's own release metadata, recovered from the Wayback Machine
# capture of 2023-05-12: 9301624f889b079c85ca15a77c299d6d. The app inside is a
# universal binary signed and notarized by "Developer ID Application: Dexter
# Leng (LQ2VH8VB84)". A mismatch aborts, so a tampered re-upload cannot land.
#
# An existing Vimac.app is NEVER replaced. Anything already installed wins —
# above all a self-built one, which the pinned 2021 binary must never silently
# overwrite.
set -e

VIMAC_VERSION="0.3.19"
VIMAC_APP="${VIMAC_APP:-/Applications/Vimac.app}"
VIMAC_SOURCE_DIR="${VIMAC_SOURCE_DIR:-$HOME/Code/active/vimac-next}"
VIMAC_SOURCE_REPO="${VIMAC_SOURCE_REPO:-helmedeiros/vimac-next}"
VIMAC_URL="${VIMAC_URL:-https://github.com/erichmond33/vimac/releases/download/vimic_lives/Vimac_distribution.zip}"
VIMAC_SHA256="${VIMAC_SHA256:-a03ac25edca2190207c70825b154d20a3c6bc5b0d7b705d1ced95a7d0961c4a0}"

# Own builds are verified by SIGNING CERTIFICATE, not by archive hash. A hash
# would have to be re-pinned for every release; the certificate is stable across
# all of them, and it is the same fact macOS uses to keep the Accessibility
# grant. Regenerating the identity means updating this value.
VIMAC_OWN_BUNDLE_ID="com.mokacoding.vimac"
VIMAC_OWN_CERT_SHA1="${VIMAC_OWN_CERT_SHA1:-b5e2f5f940fbbdf14fa1d5098fb761a82e47866f}"

# Identify an install by bundle id, not by the path — both sources land on
# /Applications/Vimac.app, and only the identifier says which one is there.
describe_install() {
  id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' \
        "$VIMAC_APP/Contents/Info.plist" 2>/dev/null || true)"
  version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' \
        "$VIMAC_APP/Contents/Info.plist" 2>/dev/null || true)"

  case "$id" in
    com.mokacoding.vimac) echo "self-built ${version:-?}" ;;
    dexterleng.vimac)     echo "pinned ${version:-?}" ;;
    "")                   echo "unrecognised (no readable bundle id)" ;;
    *)                    echo "third-party ($id ${version:-?})" ;;
  esac
}

# Install a Release build published to the private repo's GitHub releases.
# Faster than building and needs no Xcode, so this is what a second machine
# gets. The archive is authenticated by the code signature rather than a pinned
# hash — see VIMAC_OWN_CERT_SHA1 above.
install_own_release() {
  command -v gh >/dev/null 2>&1 || return 1
  gh auth status >/dev/null 2>&1 || return 1

  echo "  Fetching your published build from $VIMAC_SOURCE_REPO."
  gh release download --repo "$VIMAC_SOURCE_REPO" --pattern "Vimac.zip" \
    --dir "$work" >/dev/null 2>&1 || return 1

  ditto -x -k "$work/Vimac.zip" "$work/own" 2>/dev/null || return 1
  [ -d "$work/own/Vimac.app" ] || return 1

  # Refuse anything not signed by the expected identity. A release asset is only
  # as trustworthy as the account that published it; this checks the artefact.
  requirement="$(codesign -d -r- "$work/own/Vimac.app" 2>&1 | grep designated || true)"
  case "$requirement" in
    *"identifier \"$VIMAC_OWN_BUNDLE_ID\""*"$VIMAC_OWN_CERT_SHA1"*) ;;
    *)
      echo "  Published build is not signed by the expected identity — refusing." >&2
      echo "    got: ${requirement:-no signature}" >&2
      return 1
      ;;
  esac

  codesign --verify --strict "$work/own/Vimac.app" 2>/dev/null || {
    echo "  Published build fails signature verification — refusing." >&2
    return 1
  }

  ditto "$work/own/Vimac.app" "$VIMAC_APP"
}

build_from_source() {
  if [ ! -d "$VIMAC_SOURCE_DIR" ]; then
    echo "  No checkout at $VIMAC_SOURCE_DIR — cloning $VIMAC_SOURCE_REPO."
    mkdir -p "$(dirname "$VIMAC_SOURCE_DIR")"
    if ! git clone --quiet "git@github.com:${VIMAC_SOURCE_REPO}.git" "$VIMAC_SOURCE_DIR"; then
      echo "  Clone failed — the repo is private, so this needs SSH access to GitHub." >&2
      return 1
    fi
  fi

  if ! xcodebuild -version >/dev/null 2>&1; then
    echo "  Xcode is required to build from source — see xcode/README.md." >&2
    return 1
  fi

  echo "  Building Vimac from $VIMAC_SOURCE_DIR (this takes a few minutes)."
  # `make install` quits any running copy, builds Release, and replaces
  # /Applications/Vimac.app itself — including a pinned 0.3.19 sitting there.
  # That is the intended upgrade path, and it is why this stays opt-in.
  ( cd "$VIMAC_SOURCE_DIR" && make install )
}

if [ "${VIMAC_BUILD_FROM_SOURCE:-0}" = "1" ]; then
  if build_from_source; then
    echo "  Vimac installed from source: $(describe_install)."
  else
    echo "  Build from source skipped — leaving the current install alone." >&2
  fi
  exit 0
fi

if [ -d "$VIMAC_APP" ]; then
  echo "  Vimac already installed at $VIMAC_APP: $(describe_install) — skipping."
  exit 0
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Nothing installed. Prefer your own build — it is the maintained, audited one —
# and fall back to the pinned 2021 binary only when it cannot be had.
if [ "${VIMAC_PREFER_OWN_BUILD:-1}" = "1" ] && install_own_release; then
  echo "  Vimac installed from your published build: $(describe_install)."
  echo "  Grant it Accessibility access (System Settings › Privacy & Security ›"
  echo "  Accessibility) before first use — it cannot be scripted."
  exit 0
fi

echo "  Falling back to the pinned Vimac $VIMAC_VERSION."
if ! curl -fsSL -o "$work/Vimac.zip" "$VIMAC_URL"; then
  echo "  Download failed — skipping Vimac. See vimac/README.md for the manual route." >&2
  exit 0
fi

actual="$(shasum -a 256 "$work/Vimac.zip" | awk '{print $1}')"
if [ "$actual" != "$VIMAC_SHA256" ]; then
  echo "  Checksum mismatch — refusing to install Vimac." >&2
  echo "    expected $VIMAC_SHA256" >&2
  echo "    actual   $actual" >&2
  exit 1
fi

ditto -x -k "$work/Vimac.zip" "$work/extracted"
ditto "$work/extracted/Vimac.app" "$VIMAC_APP"

echo "  Vimac $VIMAC_VERSION installed at $VIMAC_APP."
echo "  Grant it Accessibility access (System Settings › Privacy & Security ›"
echo "  Accessibility) before first use — it cannot be scripted."
echo "  To replace it with your own build: VIMAC_BUILD_FROM_SOURCE=1 vimac/install.sh"
