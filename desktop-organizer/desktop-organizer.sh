#!/bin/sh
#
# Desktop Organizer
# Keeps ~/Desktop clean by moving settled items into Dropbox, fully automatically.
#
#   - Screenshots & screen recordings  -> ~/Dropbox/Screenshots/<year>/
#   - Everything else                  -> ~/Dropbox/Desktop-Inbox/
#
# Safe for unattended use: it never deletes, honours a grace period so files you
# are actively working on stay put, and resolves name collisions instead of
# overwriting. Run with --dry-run to preview without moving anything.
#
# Driven by launchd (see install.sh). Also runnable by hand:
#   desktop-organizer.sh            # do the sweep
#   desktop-organizer.sh --dry-run  # print what would move, change nothing

set -eu

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

DESKTOP="$HOME/Desktop"
DROPBOX="$HOME/Dropbox"
INBOX_NAME="Desktop-Inbox"
SCREENSHOTS_DIR="$DROPBOX/Screenshots"

# Items younger than this many minutes are left alone (you may still be using
# them). launchd re-runs on a timer, so they get swept on a later pass.
GRACE_MINUTES=2

# Move top-level folders too (e.g. an export dir dropped on the Desktop).
MOVE_DIRECTORIES=true

# Never touch these (glob patterns, matched against the basename).
IGNORE_GLOBS=".DS_Store .localized Icon* .*"

LOG_FILE="$HOME/Library/Logs/desktop-organizer.log"

# ---------------------------------------------------------------------------

DRY_RUN=false
case "${1:-}" in
  --dry-run|-n) DRY_RUN=true ;;
esac

log() {
  # timestamped line to the log file, and to stdout when interactive / dry-run
  line="$(date '+%Y-%m-%d %H:%M:%S') $1"
  printf '%s\n' "$line" >> "$LOG_FILE" 2>/dev/null || true
  if [ "$DRY_RUN" = true ] || [ -t 1 ]; then
    printf '%s\n' "$line"
  fi
}

# Guard: nothing to do if the Desktop or Dropbox aren't there.
[ -d "$DESKTOP" ] || { log "no Desktop at $DESKTOP, nothing to do"; exit 0; }
[ -d "$DROPBOX" ] || { log "Dropbox not found at $DROPBOX, skipping (is it synced?)"; exit 0; }

is_ignored() {
  name="$1"
  for pat in $IGNORE_GLOBS; do
    # shellcheck disable=SC2254
    case "$name" in $pat) return 0 ;; esac
  done
  return 1
}

# mtime year of a path, e.g. 2026
mtime_year() { stat -f '%Sm' -t '%Y' "$1"; }

# epoch seconds since last modification
mtime_epoch() { stat -f '%m' "$1"; }

# Decide the destination directory for an item. Prints the dir, or nothing to
# signal "leave it on the Desktop".
classify() {
  name="$1"; path="$2"
  case "$name" in
    "Screenshot "*|"Screen Shot "*|"Screen Recording "*|"CleanShot"*|"SCR-"*)
      year="$(printf '%s' "$name" | grep -oE '20[0-9]{2}' | head -1)"
      [ -n "$year" ] || year="$(mtime_year "$path")"
      printf '%s/%s' "$SCREENSHOTS_DIR" "$year"
      ;;
    *)
      printf '%s/%s' "$DROPBOX" "$INBOX_NAME"
      ;;
  esac
}

# Non-colliding destination path for basename "$1" inside dir "$2".
unique_dest() {
  name="$1"; dir="$2"
  if [ ! -e "$dir/$name" ]; then
    printf '%s/%s' "$dir" "$name"; return
  fi
  case "$name" in
    *.*) stem="${name%.*}"; ext=".${name##*.}" ;;
    *)   stem="$name"; ext="" ;;
  esac
  i=2
  while [ -e "$dir/$stem $i$ext" ]; do i=$((i + 1)); done
  printf '%s/%s %s%s' "$dir" "$stem" "$i" "$ext"
}

now="$(date '+%s')"
grace_secs=$((GRACE_MINUTES * 60))

# Only the immediate, visible contents of the Desktop. A glob is POSIX and
# safely preserves spaces/newlines in names (each match is its own word);
# hidden items aren't matched by * and are ignored by design anyway.
for path in "$DESKTOP"/*; do
  [ -e "$path" ] || continue   # empty Desktop (glob didn't match) or dangling link
  name="$(basename "$path")"

  is_ignored "$name" && continue

  if [ -d "$path" ] && [ "$MOVE_DIRECTORIES" != true ]; then
    continue
  fi

  # Grace period: skip items modified too recently.
  age=$((now - $(mtime_epoch "$path")))
  if [ "$age" -lt "$grace_secs" ]; then
    continue
  fi

  dest_dir="$(classify "$name" "$path")"
  [ -n "$dest_dir" ] || continue
  dest="$(unique_dest "$name" "$dest_dir")"

  if [ "$DRY_RUN" = true ]; then
    log "WOULD MOVE  $name  ->  ${dest#"$HOME"/}"
    continue
  fi

  mkdir -p "$dest_dir"
  if mv "$path" "$dest"; then
    log "moved  $name  ->  ${dest#"$HOME"/}"
  else
    log "FAILED to move  $name"
  fi
done

exit 0
