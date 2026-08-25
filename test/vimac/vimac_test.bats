#!/usr/bin/env bats

# Require BATS version 1.5.0 or higher for run flags
bats_require_minimum_version 1.5.0

INSTALL="${BATS_TEST_DIRNAME}/../../vimac/install.sh"

# The pinned archive: SHA-256 of the last official Vimac build (0.3.19), whose
# MD5 matches the fingerprint published by vimacapp.com's release metadata.
PINNED_SHA256="a03ac25edca2190207c70825b154d20a3c6bc5b0d7b705d1ced95a7d0961c4a0"

setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "${TEST_DIR}/bin"
  PATH="${TEST_DIR}/bin:${PATH}"
}

teardown() {
  rm -rf "${TEST_DIR}"
}

# Builds a zip holding a fake Vimac.app and stubs curl to serve it, so the
# install path can run end to end without touching the network.
a_served_archive() {
  mkdir -p "${TEST_DIR}/src/Vimac.app/Contents/MacOS"
  echo "not really an app" > "${TEST_DIR}/src/Vimac.app/Contents/MacOS/Vimac"
  ditto -c -k --sequesterRsrc --keepParent \
    "${TEST_DIR}/src/Vimac.app" "${TEST_DIR}/served.zip"

  cat > "${TEST_DIR}/bin/curl" <<EOF
#!/bin/sh
# Stub curl: copy the served archive to the -o destination.
while [ \$# -gt 0 ]; do
  case "\$1" in
    -o) dest="\$2"; shift 2 ;;
    *) shift ;;
  esac
done
cp "${TEST_DIR}/served.zip" "\$dest"
EOF
  chmod +x "${TEST_DIR}/bin/curl"

  shasum -a 256 "${TEST_DIR}/served.zip" | awk '{print $1}'
}

a_failing_download() {
  cat > "${TEST_DIR}/bin/curl" <<'EOF'
#!/bin/sh
exit 22
EOF
  chmod +x "${TEST_DIR}/bin/curl"
}

# --- Pinning ---

@test "install.sh pins the official 0.3.19 archive checksum" {
  grep -q "${PINNED_SHA256}" "${INSTALL}"
}

@test "install.sh records the App Center fingerprint the pin was derived from" {
  grep -q "9301624f889b079c85ca15a77c299d6d" "${INSTALL}"
}

# --- Never regress an existing install ---

# Writes a fake Vimac.app carrying a given bundle id, so the script's source
# detection can be exercised without installing anything real.
an_installed_app_with_id() {
  app="${TEST_DIR}/Applications/Vimac.app"
  mkdir -p "${app}/Contents"
  cat > "${app}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key><string>$1</string>
  <key>CFBundleShortVersionString</key><string>$2</string>
</dict>
</plist>
EOF
}

# The regression this guards: bin/dot must never quietly put the 2021 binary
# back over a build the user chose to run.
@test "never replaces a self-built Vimac with the pinned binary" {
  an_installed_app_with_id "com.mokacoding.vimac" "0.4.0"
  a_served_archive > /dev/null   # a download would succeed if one were attempted

  run env VIMAC_APP="${TEST_DIR}/Applications/Vimac.app" \
          VIMAC_URL="https://example.invalid/Vimac.zip" \
          "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"self-built 0.4.0"* ]]
  # The fake app has no real binary; a download would have overwritten it.
  [ ! -f "${TEST_DIR}/Applications/Vimac.app/Contents/MacOS/Vimac" ]
}

@test "recognises the pinned binary and leaves it alone" {
  an_installed_app_with_id "dexterleng.vimac" "0.3.19"

  run env VIMAC_APP="${TEST_DIR}/Applications/Vimac.app" "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"pinned 0.3.19"* ]]
}

@test "leaves an unrecognised app at that path alone rather than clobbering it" {
  an_installed_app_with_id "com.example.somethingelse" "9.9"

  run env VIMAC_APP="${TEST_DIR}/Applications/Vimac.app" "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"third-party"* ]]
}

# --- Build from source ---

@test "building from source without a checkout does not break dot" {
  run env VIMAC_BUILD_FROM_SOURCE=1 \
          VIMAC_SOURCE_DIR="${TEST_DIR}/nonexistent" \
          VIMAC_APP="${TEST_DIR}/Applications/Vimac.app" \
          "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"No source checkout"* ]]
  [[ "$output" == *"leaving the current install alone"* ]]
}

@test "building from source is opt-in, never the default" {
  # A plain run must not shell out to make, however tempting a checkout is.
  grep -q 'VIMAC_BUILD_FROM_SOURCE:-0' "${INSTALL}"
}

# --- Behaviour ---

@test "installs the app when the checksum matches" {
  sha="$(a_served_archive)"

  run env VIMAC_APP="${TEST_DIR}/Applications/Vimac.app" \
          VIMAC_URL="https://example.invalid/Vimac.zip" \
          VIMAC_SHA256="${sha}" \
          "${INSTALL}"

  [ "$status" -eq 0 ]
  [ -d "${TEST_DIR}/Applications/Vimac.app" ]
  [ -f "${TEST_DIR}/Applications/Vimac.app/Contents/MacOS/Vimac" ]
}

@test "refuses to install when the checksum does not match" {
  a_served_archive > /dev/null

  run env VIMAC_APP="${TEST_DIR}/Applications/Vimac.app" \
          VIMAC_URL="https://example.invalid/Vimac.zip" \
          VIMAC_SHA256="0000000000000000000000000000000000000000000000000000000000000000" \
          "${INSTALL}"

  [ "$status" -ne 0 ]
  [[ "$output" == *"Checksum mismatch"* ]]
  [ ! -d "${TEST_DIR}/Applications/Vimac.app" ]
}

@test "is idempotent: skips when Vimac is already installed" {
  a_served_archive > /dev/null
  mkdir -p "${TEST_DIR}/Applications/Vimac.app"

  run env VIMAC_APP="${TEST_DIR}/Applications/Vimac.app" \
          VIMAC_URL="https://example.invalid/Vimac.zip" \
          "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"already installed"* ]]
}

@test "a failed download does not break dot" {
  a_failing_download

  run env VIMAC_APP="${TEST_DIR}/Applications/Vimac.app" \
          VIMAC_URL="https://example.invalid/Vimac.zip" \
          "${INSTALL}"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Download failed"* ]]
  [ ! -d "${TEST_DIR}/Applications/Vimac.app" ]
}
