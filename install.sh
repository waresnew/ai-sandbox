#!/bin/bash
set -euo pipefail
SRC="run.sh"
DST="$HOME/.local/bin/sbx"
mkdir -p "$(dirname "$DST")"
cp -i "$SRC" "$DST"
chmod +x "$DST"

echo "Copied $SRC to $DST"
