#!/bin/bash
set -euo pipefail
RUN_SRC="run.sh"
RUN_DST="$HOME/.local/bin/sbx"
mkdir -p "$(dirname "$RUN_DST")"
cp "$RUN_SRC" "$RUN_DST"
chmod +x "$RUN_DST"
echo "Copied $RUN_SRC to $RUN_DST"

CONFIG_DIR="$HOME/.config/ai-sandbox"
PROXY_SRC="proxy"
PROXY_DST="$CONFIG_DIR"
mkdir -p "$CONFIG_DIR"
cp -r "$PROXY_SRC" "$PROXY_DST"
echo -e "Filter \"$PROXY_DST/proxy/domain_whitelist.txt\"" >>$PROXY_DST/proxy/tinyproxy.conf
echo "Copied $PROXY_SRC to $PROXY_DST"
