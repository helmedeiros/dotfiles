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
VIMAC_URL="${VIMAC_URL:-https://github.com/erichmond33/vimac/releases/download/vimic_lives/Vimac_distribution.zip}"
VIMAC_SHA256="${VIMAC_SHA256:-a03ac25edca2190207c70825b154d20a3c6bc5b0d7b705d1ced95a7d0961c4a0}"

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

build_from_source() {
  if [ ! -d "$VIMAC_SOURCE_DIR" ]; then
    echo "  No source checkout at $VIMAC_SOURCE_DIR." >&2
    echo "  Clone it first: git clone git@github.com:helmedeiros/vimac-next.git \\" >&2
    echo "    $VIMAC_SOURCE_DIR" >&2
    return 1
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

echo "  Downloading Vimac $VIMAC_VERSION (pinned fallback)."
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
