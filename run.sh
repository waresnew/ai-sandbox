#!/bin/bash
set -euo pipefail
container image pull ghcr.io/waresnew/ai-sandbox:latest
container run --rm -it \
    --cap-drop ALL \
    --mount type=bind,src="$(pwd)",dst=/home/agent/project \
    --mount type=bind,src="$HOME/.claude",dst=/home/agent/.claude \
    --mount type=bind,src="$HOME/.codex",dst=/home/agent/.codex \
    ghcr.io/waresnew/ai-sandbox:latest "$@"
