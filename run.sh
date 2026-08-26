#!/bin/bash
set -euo pipefail
ARCH="$(uname -m)"
case "$ARCH" in
arm64) PLATFORM="linux/arm64" ;;
x86_64) PLATFORM="linux/amd64" ;;
*)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac
container image pull --platform "$PLATFORM" ghcr.io/waresnew/ai-sandbox:latest
container run --rm -it \
    --cap-drop ALL \
    --mount type=bind,src="$(pwd)",dst=/home/agent/project \
    --mount type=bind,src="$HOME/.claude",dst=/home/agent/.claude \
    --mount type=bind,src="$HOME/.codex",dst=/home/agent/.codex \
    --env TERM="$TERM" \
    ghcr.io/waresnew/ai-sandbox:latest "$@"
