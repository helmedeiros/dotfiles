#!/usr/bin/env bash
#
# Bind file extensions to applications based on per-app `filetypes` files.
#
# Discovery: any `*/filetypes` file in the dotfiles root is sourced as bash and
# must define:
#   APP="Foo.app"            # resolved against /Applications/$APP
#   EXTENSIONS=(ext1 ext2)   # extensions to claim (no leading dot)
#
# Apps whose .app isn't installed are silently skipped, so removing a brew
# cask (or the whole app folder) cleanly disables its bindings on the next
# run. When two folders claim the same extension, last glob match wins
# (alphabetical order); this is documented behavior, not a bug.
#
# Requires `duti` (brew install duti).

set -u

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

if ! command -v duti >/dev/null 2>&1; then
  echo "bind-filetypes: duti not installed; skipping" >&2
  exit 0
fi

shopt -s nullglob
for ftfile in "$DOTFILES_ROOT"/*/filetypes; do
  (
    APP=""
    EXTENSIONS=()
    # shellcheck disable=SC1090
    . "$ftfile"

    if [ -z "$APP" ]; then
      echo "bind-filetypes: $ftfile missing APP=; skipping" >&2
      exit 0
    fi
    if [ ! -d "/Applications/$APP" ]; then
      exit 0
    fi
    bundle_id=$(defaults read "/Applications/$APP/Contents/Info" CFBundleIdentifier 2>/dev/null) || {
      echo "bind-filetypes: could not read bundle id for $APP" >&2
      exit 0
    }

    for ext in "${EXTENSIONS[@]}"; do
      err=$(duti -s "$bundle_id" ".$ext" all 2>&1 >/dev/null || true)
      # Extensions without a system-registered UTI resolve to a synthetic
      # `dyn.*` identifier that LaunchServices refuses to bind (error -50).
      # These extensions still typically open in the right app via UTI
      # inheritance (their dyn UTI conforms to public.plain-text /
      # public.source-code, which the target app already handles), so the
      # error is cosmetic — swallow it. Real errors still surface.
      if [ -n "$err" ] && ! printf '%s\n' "$err" | grep -q 'dyn\.[^ ]* (error -50)'; then
        printf '%s\n' "$err" >&2
      fi
    done
  )
done
