# Environment

You are running inside a Docker container.

- `~/project` is the project directory and is mounted from the host.
- Changes to `~/project` persist to the host.
- The container filesystem is otherwise ephemeral.
- You are running as a non-root user without sudo.
- Your agent configuration is mounted from the host; treat it as persistent user state.
- Network access is available.
- Do not modify files outside `~/project` unless explicitly required.
