#!/bin/sh
#
# Desktop Organizer install script
# Renders the launchd agent from the template and (re)loads it. Idempotent.

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
LABEL="com.helmedeiros.desktop-organizer"
SCRIPT="$SCRIPT_DIR/desktop-organizer.sh"
RUNNER_SRC="$SCRIPT_DIR/runner.c"
RUNNER_BIN="$SCRIPT_DIR/desktop-organizer-runner"
TEMPLATE="$SCRIPT_DIR/$LABEL.plist.template"
AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST="$AGENTS_DIR/$LABEL.plist"
LOG_FILE="$HOME/Library/Logs/desktop-organizer.log"

printf "Installing Desktop Organizer.\n"

chmod +x "$SCRIPT"
mkdir -p "$AGENTS_DIR"
touch "$LOG_FILE"

# Build the narrow FDA helper. Only (re)compile when the source is newer than
# the binary — an ad-hoc signature changes on every rebuild, which would
# invalidate the Full Disk Access grant, so we avoid rebuilding on every dot run.
if ! command -v cc >/dev/null 2>&1; then
  printf "ERROR: no C compiler (cc) found. Install Xcode Command Line Tools:\n"
  printf "  xcode-select --install\n"
  exit 1
fi
if [ ! -x "$RUNNER_BIN" ] || [ "$RUNNER_SRC" -nt "$RUNNER_BIN" ]; then
  printf "Compiling FDA helper (desktop-organizer-runner).\n"
  cc -O2 -DSCRIPT_PATH="\"$SCRIPT\"" -o "$RUNNER_BIN" "$RUNNER_SRC"
  codesign --force --sign - "$RUNNER_BIN" >/dev/null 2>&1 || true
  printf "NOTE: (re)compiled helper — re-grant Full Disk Access to it if it was already granted.\n"
fi

# Render the plist with this machine's absolute paths.
sed -e "s#__PROGRAM__#$RUNNER_BIN#g" \
    -e "s#__DESKTOP__#$HOME/Desktop#g" \
    -e "s#__LOG__#$LOG_FILE#g" \
    "$TEMPLATE" > "$PLIST"

# Reload: bootout any previous instance, then bootstrap the fresh plist.
uid="$(id -u)"
launchctl bootout "gui/$uid/$LABEL" 2>/dev/null || true
if launchctl bootstrap "gui/$uid" "$PLIST" 2>/dev/null; then
  printf "Desktop Organizer agent loaded (%s).\n" "$LABEL"
else
  # Fall back to legacy load for older macOS.
  launchctl unload "$PLIST" 2>/dev/null || true
  launchctl load "$PLIST"
  printf "Desktop Organizer agent loaded via legacy launchctl.\n"
fi

printf "Logs: %s\n" "$LOG_FILE"
printf "Desktop Organizer installation complete.\n"
