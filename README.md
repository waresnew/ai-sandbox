# AI Sandbox

This setup restricts filesystem and network access for running AI coding tools, with the goal of keeping it as simple as possible.

- Filesystem access is limited to the host's current working directory and common config folders like ~/.claude. Although those config folders can contain authentication keys, the outbound domain whitelist limits where they can be sent.
- Outbound network requests are controlled by blocking the container from accessing the internet except through a proxy, which does domain-based filtering.
- Despite the container being created fresh every run, downloaded dependencies and build caches are still preserved if they get stored in the project directory (which is often the case: `node_modules`, `.venv`, `target`).

## Usage

Run `install.sh`, which will add `sbx` to your PATH. Then, run `sbx` in your project folder.

## Requirements

Most of these requirements can be worked around by editing the script yourself:

- tinyproxy
- python
- Apple container
