#!/bin/sh
#
# Vimac — keyboard-driven navigation of the macOS GUI (hint-mode, scroll-mode).
#
# Vimac was discontinued in 2022 in favour of the paid Homerow. There is no
# Homebrew cask, vimacapp.com is offline, and the App Center download link in
# its release metadata expired on 2023-05-13. The last official build (0.3.19,
# April 2021) survives only as a verbatim re-upload in a fork's GitHub release,
# so this script pins the archive by hash instead of trusting the host.
#
# VIMAC_SHA256 is the checksum of the archive whose MD5 equals the
# `fingerprint` field in vimacapp.com's own release metadata (recovered from
# the Wayback Machine capture of 2023-05-12): 9301624f889b079c85ca15a77c299d6d.
# The app inside is a universal x86_64/arm64 binary, signed and notarized by
# "Developer ID Application: Dexter Leng (LQ2VH8VB84)". A mismatch aborts the
# install, so a tampered re-upload can never reach /Applications.
set -e

VIMAC_VERSION="0.3.19"
VIMAC_APP="${VIMAC_APP:-/Applications/Vimac.app}"
VIMAC_URL="${VIMAC_URL:-https://github.com/erichmond33/vimac/releases/download/vimic_lives/Vimac_distribution.zip}"
VIMAC_SHA256="${VIMAC_SHA256:-a03ac25edca2190207c70825b154d20a3c6bc5b0d7b705d1ced95a7d0961c4a0}"

if [ -d "$VIMAC_APP" ]; then
  echo "  Vimac already installed at $VIMAC_APP — skipping."
  exit 0
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "  Downloading Vimac $VIMAC_VERSION."
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
