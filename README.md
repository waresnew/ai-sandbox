# AI Sandbox

This setup makes a *reasonable effort* to restrict filesystem and network access for running AI coding tools, with the goal of keeping it as simple as possible.

## Sandbox priorities

In descending order:

1. Restrict filesystem access.
  By only mounting the host's current working directory and common config folders like ~/.claude, filesystem access is on a whitelist basis.
2. Restrict outbound network requests.
  Outbound network requests are controlled by blocking the container from accessing the internet except through a proxy, which does domain-based filtering.
3. Preserve the functionality of the AI agent.
  Developer tools like uv, cargo, npm are preinstalled. Also, despite the container being created fresh every run, downloaded dependencies and build caches are still preserved if they get stored in the project directory (which is often the case).

## Limitations

- AI can still generate malicious code in the project (or in any of the mounted directories) that you may accidentally or automatically run.
- The sandbox can access host services that are exposed via 0.0.0.0, which can leak data.
- The mounted config folders can contain authentication keys, which could be leaked, but the outbound domain whitelist limits where they can be sent.
- The outbound whitelist is domain-based, so allowing certain domains, like github.com, that let users receive data would have greater risk.

## Usage

Run `install.sh`, which will add `sbx` to your PATH. Then, run `sbx` in your project folder.

## Updating

If the update was related to the Dockerfile, running `sbx` again will re-pull the latest version. You should prune the unused image after.

If the update was related to the tinyproxy config or `run.sh`, you need to run `install.sh` again.

## Requirements

Most of these requirements can be worked around by editing the script yourself:

- tinyproxy
- python
- Apple container

## Troubleshooting

Proxy logs are temporarily stored in ~/.config/ai-sandbox/****_proxy.log
