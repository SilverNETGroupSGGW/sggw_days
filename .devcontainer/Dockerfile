FROM mcr.microsoft.com/devcontainers/base:trixie

ARG FLUTTER_CHANNEL=stable
ARG FLUTTER_INSTALL_DIR=/develop
ARG ANDROID_SDK_ROOT=/home/vscode/android-sdk
ARG PUB_CACHE=/home/vscode/.pub-cache
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_INSTALL_DIR=${FLUTTER_INSTALL_DIR}
ENV ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}
ENV ANDROID_HOME=${ANDROID_SDK_ROOT}
ENV JAVA_HOME=/usr/lib/jvm/default-java
ENV PUB_CACHE=${PUB_CACHE}
ENV PATH="${JAVA_HOME}/bin:${FLUTTER_INSTALL_DIR}/flutter/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/emulator:${PUB_CACHE}/bin:${PATH}"

RUN apt-get update -y && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip libglu1-mesa ca-certificates jq openjdk-21-jdk-headless \
    && ln -sfn "/usr/lib/jvm/java-21-openjdk-$(dpkg --print-architecture)" "${JAVA_HOME}" \
    && rm -rf /var/lib/apt/lists/*

COPY .devcontainer/install-firebase-cli.sh /tmp/install-firebase-cli.sh
RUN bash /tmp/install-firebase-cli.sh && rm /tmp/install-firebase-cli.sh

COPY .devcontainer/install-flutter.sh /tmp/install-flutter.sh
COPY .devcontainer/install-android-sdk.sh /tmp/install-android-sdk.sh
RUN FLUTTER_CHANNEL=${FLUTTER_CHANNEL} TARGETARCH=${TARGETARCH} \
    bash /tmp/install-flutter.sh && rm /tmp/install-flutter.sh
RUN ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT} FLUTTER_INSTALL_DIR=${FLUTTER_INSTALL_DIR} \
    bash /tmp/install-android-sdk.sh && rm /tmp/install-android-sdk.sh

RUN mkdir -p ${PUB_CACHE} \
    && chown -R vscode:vscode ${FLUTTER_INSTALL_DIR} ${ANDROID_SDK_ROOT} ${PUB_CACHE}

USER vscode

RUN git config --global --add safe.directory ${FLUTTER_INSTALL_DIR}/flutter \
    && flutter config --android-sdk ${ANDROID_SDK_ROOT} \
    && flutter config --disable-analytics \
    && dart pub global activate flutterfire_cli \
    && [ "${TARGETARCH}" = "arm64" ] || flutter precache --linux \
    && firebase --version \
    && flutterfire --version \
    # Fetch remote tags so git describe works; this writes the correct version
    # into flutter.version.json (otherwise it defaults to 0.0.0-unknown).
    && flutter --version \
    && jq -r '.frameworkVersion' "${FLUTTER_INSTALL_DIR}/flutter/bin/cache/flutter.version.json" \
    > "${FLUTTER_INSTALL_DIR}/flutter/version"
