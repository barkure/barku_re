#!/bin/sh

set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
FONT_URL='https://raw.githubusercontent.com/googlefonts/roboto-2/main/src/variable/Roboto%5Bwdth%2Cwght%5D.ttf'
OUTPUT="$ROOT/static/fonts/Roboto.woff2"

# Latin + Latin-1 Supplement covers the English UI copy.
UNICODES=${1:-U+0020-007E,U+00A0-00FF}

printf 'Unicode range: %s\n' "$UNICODES"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

curl -fL --retry 3 --output "$WORK_DIR/Roboto-Variable.ttf" "$FONT_URL"

uvx --from 'fonttools[woff]' fonttools varLib.instancer \
  "$WORK_DIR/Roboto-Variable.ttf" \
  wdth=100 \
  wght=400:700 \
  -o "$WORK_DIR/Roboto-instanced.ttf"

uvx --from 'fonttools[woff]' pyftsubset \
  "$WORK_DIR/Roboto-instanced.ttf" \
  --output-file="$OUTPUT" \
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

printf 'Generated %s (%s bytes)\n' "$OUTPUT" "$(wc -c < "$OUTPUT" | tr -d ' ')"
