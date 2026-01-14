ARG BUILD_FROM
FROM ${BUILD_FROM}

# Labels
LABEL maintainer="Robson Felix"
LABEL org.opencontainers.image.title="Claude Code for Home Assistant"
LABEL org.opencontainers.image.description="Claude Code CLI with web terminal and HA integration"
LABEL org.opencontainers.image.source="https://github.com/robsonfelix/robsonfelix-hass-addons"
LABEL org.opencontainers.image.licenses="MIT"

# Environment setup
ENV \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color

# Install system dependencies (ttyd installed separately as static binary)
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    nodejs \
    npm \
    openssh-client \
    libstdc++ \
    ncurses \
    vim \
    nano \
    tmux \
    coreutils \
    findutils \
    grep \
    sed \
    gawk \
    ca-certificates \
    openssl \
    ripgrep \
    && update-ca-certificates

# Install ttyd static binary (avoids libwebsockets issues)
ARG BUILD_ARCH
RUN case "${BUILD_ARCH}" in \
        amd64) TTYD_ARCH="x86_64" ;; \
        aarch64) TTYD_ARCH="aarch64" ;; \
        armv7|armhf) TTYD_ARCH="armhf" ;; \
        i386) TTYD_ARCH="i686" ;; \
        *) TTYD_ARCH="x86_64" ;; \
    esac && \
    curl -fsSL "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TTYD_ARCH}" -o /usr/bin/ttyd && \
    chmod +x /usr/bin/ttyd

# Install Claude Code via npm
RUN npm install -g @anthropic-ai/claude-code

# Install hass-mcp for Home Assistant integration
RUN pip3 install --no-cache-dir --break-system-packages hass-mcp

# Create necessary directories
RUN mkdir -p \
    /data \
    /homeassistant \
    /root/.claude \
    /root/.config/claude-code \
    /root/.local/bin

# Set up PATH
ENV PATH="/root/.local/bin:${PATH}"

# Set working directory
WORKDIR /homeassistant

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -sf http://localhost:7681/ || exit 1

# Run ttyd directly - no script needed
ENTRYPOINT []
CMD ["/bin/bash", "-c", "cd /homeassistant && exec ttyd --port 7681 --writable --ping-interval 30 --max-clients 5 bash --login"]
