#!/bin/sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

# Latin + Latin-1 Supplement covers the English UI copy.
UNICODES=${1:-U+0020-007E,U+00A0-00FF}

printf 'Unicode range: %s\n' "$UNICODES"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

# subset_font <name> <url> [varLib.instancer axis args...]
subset_font() {
  name=$1
  url=$2
  shift 2

  curl -fL --retry 3 --output "$WORK_DIR/$name.ttf" "$url"

  src="$WORK_DIR/$name.ttf"
  if [ $# -gt 0 ]; then
    uvx --from 'fonttools[woff]' fonttools varLib.instancer \
      "$src" \
      "$@" \
      -o "$WORK_DIR/$name-instanced.ttf"
    src="$WORK_DIR/$name-instanced.ttf"
  fi

  uvx --from 'fonttools[woff]' pyftsubset \
    "$src" \
    --output-file="$ROOT/static/fonts/$name.woff2" \
    --flavor=woff2 \
    --unicodes="$UNICODES" \
    --layout-features='kern,liga,calt' \
    --name-IDs='*' \
    --name-legacy \
    --name-languages='*' \
    --notdef-glyph \
    --notdef-outline \
    --recommended-glyphs \
    --recalc-bounds

  printf 'Generated %s (%s bytes)\n' "$ROOT/static/fonts/$name.woff2" "$(wc -c < "$ROOT/static/fonts/$name.woff2" | tr -d ' ')"
}

subset_font Roboto \
  'https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/Roboto%5Bwdth%2Cwght%5D.ttf' \
  wdth=100 wght=400:700

subset_font PlayfairDisplay-Italic \
  'https://raw.githubusercontent.com/google/fonts/main/ofl/playfairdisplay/PlayfairDisplay-Italic%5Bwght%5D.ttf' \
  wght=400:600
