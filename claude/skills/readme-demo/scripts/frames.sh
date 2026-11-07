#!/usr/bin/env bash
set -euo pipefail
gif="$1"
out="${2:-$(mktemp -d)}"
mkdir -p "$out"
name="$(basename "$gif" .gif)"
n="$(ffprobe -v error -count_frames -select_streams v -show_entries stream=nb_read_frames -of csv=p=0 "$gif")"
step=$(( n / 4 + 1 ))
ffmpeg -y -loglevel error -i "$gif" -vf "select=not(mod(n\,$step)),scale=640:-1,tile=2x2" -fps_mode vfr -frames:v 1 "$out/$name.png"
size="$(du -h "$gif" | cut -f1)"
echo "$out/$name.png  ($n frames, $size)"
