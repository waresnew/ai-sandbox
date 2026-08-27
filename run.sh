#!/bin/bash
set -euo pipefail
CONFIG_DIR="$HOME/.config/ai-sandbox"
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
tmp_config_file="$CONFIG_DIR/.$$.conf"
cp "$CONFIG_DIR/proxy/tinyproxy.tmpl.conf" "$tmp_config_file"
proxy_port="$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1])')" # https://unix.stackexchange.com/a/478529
echo "Port $proxy_port" >>$tmp_config_file
tinyproxy -d -c "$tmp_config_file" >/dev/null 2>&1 &
proxy_pid=$!
handle_exit() {
    kill "$proxy_pid"
    rm -f $tmp_config_file
}
trap handle_exit EXIT
host_ip="$(container network inspect "$CONTAINER_NETWORK_NAME" | jq -r '.[0].status.ipv4Gateway')" # HACK: not sure if this is the best way to grab it
container image pull --platform "$PLATFORM" ghcr.io/waresnew/ai-sandbox:latest
container run --rm -it \
    --cap-drop ALL \
    --network "$CONTAINER_NETWORK_NAME" \
    --env TERM="$TERM" \
    --env HTTP_PROXY="http://$host_ip:$proxy_port" \
    --env HTTPS_PROXY="http://$host_ip:$proxy_port" \
    --mount type=bind,src="$(pwd)",dst=/home/agent/project \
    --mount type=bind,src="$HOME/.claude",dst=/home/agent/.claude \
    --mount type=bind,src="$HOME/.codex",dst=/home/agent/.codex \
    ghcr.io/waresnew/ai-sandbox:latest $cmd
