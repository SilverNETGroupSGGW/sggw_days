#!/usr/bin/env bash
# Installs Flutter into $FLUTTER_INSTALL_DIR.
# Expects FLUTTER_INSTALL_DIR, FLUTTER_CHANNEL, and TARGETARCH as environment variables.
set -euo pipefail

RELEASES="https://storage.googleapis.com/flutter_infra_release/releases"

mkdir -p "${FLUTTER_INSTALL_DIR}"

if [ "${TARGETARCH}" = "arm64" ]; then
    # ARM64: use the pre-built SDK from zhzhzhy/Flutter-SDK-ARM64 (bundles engine artifacts).
    curl -fsSL -o /tmp/flutter-arm64.zip \
        "https://github.com/zhzhzhy/Flutter-SDK-ARM64/releases/latest/download/Flutter-SDK-ARM64.zip"
    unzip -q /tmp/flutter-arm64.zip -d "${FLUTTER_INSTALL_DIR}/"
    rm /tmp/flutter-arm64.zip
else
    # x86_64: download the official Flutter release from Google storage.
    JSON=$(curl -fsSL "${RELEASES}/releases_linux.json")
    HASH=$(echo "${JSON}" | jq -r ".current_release.${FLUTTER_CHANNEL}")
    ARCHIVE=$(echo "${JSON}" | jq -r ".releases[] | select(.hash==\"${HASH}\" and .channel==\"${FLUTTER_CHANNEL}\") | .archive")
    curl -fsSL "${RELEASES}/${ARCHIVE}" | tar -xJ -C "${FLUTTER_INSTALL_DIR}/"
fi
