# TODO: block outbound traffic in container
FROM debian:trixie-slim
LABEL org.opencontainers.image.source=https://github.com/waresnew/ai-sandbox

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install -y --no-install-recommends \
    bubblewrap \
    ca-certificates \
    curl \
    git \
    less \
    procps \
    unzip \
    zip \
    jq \
    ripgrep \
    fd-find \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash agent
WORKDIR /home/agent
USER agent

RUN mkdir -p ~/.local/bin && ln -s $(which fdfind) ~/.local/bin/fd
ENV PATH="/home/agent/.local/bin:${PATH}"

# don't need to preinstall python/node
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN curl -fsSL https://claude.ai/install.sh | bash

# codex install script places binary in ~/.codex which conflicts with the host mount
RUN source "$HOME/.nvm/nvm.sh" \
    && nvm install --lts \
    && npm install -g @openai/codex


COPY AGENTS.md /home/agent/AGENTS.md
WORKDIR /home/agent/project

CMD ["/bin/bash"]
