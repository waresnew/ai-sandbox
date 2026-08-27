#!/bin/bash
set -euo pipefail
if [[ $(basename "$0") == "run.sh" ]]; then
    echo "Do not run this script directly: instead run install.sh" >&2
    exit 1
fi
CONFIG_DIR="$HOME/.config/ai-sandbox"
CONTAINER_NETWORK_NAME="ai-sandbox-net"
read -p "Confirm the mounting of $(pwd): [y/N]"
echo
if [[ ! $REPLY =~ ^[yY]$ ]]; then
    exit 1
fi

setup_platform_specific_stuff() {
    arch="$(uname -m)"
    case "$arch" in
    arm64) platform="linux/arm64" ;;
    x86_64) platform="linux/amd64" ;;
    *)
        echo "Unsupported architecture: $arch" >&2
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
}
setup_proxy() {
    if ! container network inspect "$CONTAINER_NETWORK_NAME" >/dev/null 2>&1; then
        container network create --internal "$CONTAINER_NETWORK_NAME"
    fi
    tmp_config_file="$CONFIG_DIR/.$$.conf"
    PROXY_LOG_FILE="$CONFIG_DIR/$$_proxy.log"
    cp "$CONFIG_DIR/proxy/tinyproxy.tmpl.conf" "$tmp_config_file"
    proxy_port="$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1])')" # https://unix.stackexchange.com/a/478529 NOTE: the port can get used by someone else between proxy_port=... and tinyproxy -d -c ...
    echo "Port $proxy_port" >>"$tmp_config_file"
    tinyproxy -d -c "$tmp_config_file" >"$PROXY_LOG_FILE" 2>&1 &
    proxy_pid=$!
}
handle_exit() {
    kill "$proxy_pid" 2>/dev/null || true
    rm -f "$tmp_config_file"
    rm -f "$PROXY_LOG_FILE"
}
trap handle_exit EXIT
setup_platform_specific_stuff
setup_proxy
host_ip="$(container network inspect "$CONTAINER_NETWORK_NAME" | jq -r '.[0].status.ipv4Gateway')" # HACK: not sure if this is the best way to grab it
container image pull --platform "$platform" ghcr.io/waresnew/ai-sandbox:latest
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
