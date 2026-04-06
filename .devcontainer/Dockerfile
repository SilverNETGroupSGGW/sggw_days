FROM mcr.microsoft.com/devcontainers/base:trixie

ARG FLUTTER_CHANNEL=stable
ARG FLUTTER_INSTALL_DIR=/develop
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_INSTALL_DIR=${FLUTTER_INSTALL_DIR}
ENV PATH="${FLUTTER_INSTALL_DIR}/flutter/bin:${HOME}/.pub-cache/bin:${PATH}"

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip libglu1-mesa ca-certificates jq \
    && rm -rf /var/lib/apt/lists/*

ADD firebase.tools /tmp/firebase.tools
RUN chmod +x /tmp/firebase.tools && /tmp/firebase.tools

COPY .devcontainer/install-flutter.sh /tmp/install-flutter.sh
RUN FLUTTER_CHANNEL=${FLUTTER_CHANNEL} TARGETARCH=${TARGETARCH} \
    bash /tmp/install-flutter.sh && rm /tmp/install-flutter.sh

RUN chown -R vscode:vscode ${FLUTTER_INSTALL_DIR}

USER vscode

RUN git config --global --add safe.directory ${FLUTTER_INSTALL_DIR}/flutter \
    && flutter config --disable-analytics \
    && [ "${TARGETARCH}" = "arm64" ] || flutter precache --linux \
    # Fetch remote tags so git describe works; this writes the correct version
    # into flutter.version.json (otherwise it defaults to 0.0.0-unknown).
    && flutter --version \
    && jq -r '.frameworkVersion' "${FLUTTER_INSTALL_DIR}/flutter/bin/cache/flutter.version.json" \
    > "${FLUTTER_INSTALL_DIR}/flutter/version"
