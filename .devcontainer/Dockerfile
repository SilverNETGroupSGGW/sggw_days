FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:trixie

ARG FLUTTER_CHANNEL=stable
ARG FLUTTER_INSTALL_DIR=/develop

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_INSTALL_DIR=${FLUTTER_INSTALL_DIR}
ENV PATH="${FLUTTER_INSTALL_DIR}/flutter/bin:${PATH}"

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${FLUTTER_INSTALL_DIR} \
    && RELEASES="https://storage.googleapis.com/flutter_infra_release/releases" \
    && JSON=$(curl -fsSL "${RELEASES}/releases_linux.json") \
    && HASH=$(echo "$JSON" | jq -r ".current_release.${FLUTTER_CHANNEL}") \
    && ARCHIVE=$(echo "$JSON" | jq -r ".releases[] | select(.hash==\"$HASH\" and .channel==\"${FLUTTER_CHANNEL}\") | .archive") \
    && curl -fsSL "${RELEASES}/${ARCHIVE}" | tar -xJ -C ${FLUTTER_INSTALL_DIR}/

RUN chown -R vscode:vscode ${FLUTTER_INSTALL_DIR}

USER vscode

RUN git config --global --add safe.directory ${FLUTTER_INSTALL_DIR}/flutter \
    && ${FLUTTER_INSTALL_DIR}/flutter/bin/flutter config --disable-analytics \
    && ${FLUTTER_INSTALL_DIR}/flutter/bin/flutter precache --linux
