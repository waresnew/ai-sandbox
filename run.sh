#!/bin/bash
set -euo pipefail
read -p "Confirm the mounting of $(pwd): [y/N]"
echo
if [[ ! $REPLY =~ ^[yY]$ ]]; then
    echo "Aborted."
    exit 1
fi

ARCH="$(uname -m)"
case "$ARCH" in
arm64) PLATFORM="linux/arm64" ;;
x86_64) PLATFORM="linux/amd64" ;;
*)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac
case "$TERM" in
xterm-kitty)
    cmd="kitten run-shell --shell=/bin/bash"
    ;;
*)
    cmd="/bin/bash"
    ;;
esac
CONTAINER_NETWORK_NAME="ai-sandbox-net"
if ! container network inspect "$CONTAINER_NETWORK_NAME" >/dev/null 2>&1; then
    container network create --internal "$CONTAINER_NETWORK_NAME"
fi
tinyproxy -d -c "$CONFIG_DIR/proxy/tinyproxy.conf" >/dev/null 2>&1 &
proxy_pid=$!
trap 'kill "$proxy_pid" 2>/dev/null' EXIT INT TERM                                                 # NOTE: this won't work well if i run this script multiple times simultaneously
HOST_IP="$(container network inspect "$CONTAINER_NETWORK_NAME" | jq -r '.[0].status.ipv4Gateway')" # HACK: not sure if this is the best way to grab it
container image pull --platform "$PLATFORM" ghcr.io/waresnew/ai-sandbox:latest
container run --rm -it \
    --cap-drop ALL \
    --network "$CONTAINER_NETWORK_NAME" \
    --env TERM="$TERM" \
    --env HTTP_PROXY="http://$HOST_IP:8888" \
    --env HTTPS_PROXY="http://$HOST_IP:8888" \
    --mount type=bind,src="$(pwd)",dst=/home/agent/project \
    --mount type=bind,src="$HOME/.claude",dst=/home/agent/.claude \
    --mount type=bind,src="$HOME/.codex",dst=/home/agent/.codex \
    ghcr.io/waresnew/ai-sandbox:latest $cmd
