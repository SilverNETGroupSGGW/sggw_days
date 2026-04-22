#!/usr/bin/env bash
set -euo pipefail

flutter config --android-sdk "${ANDROID_SDK_ROOT}"

if [ -d android ]; then
    local_properties="android/local.properties"
    tmp_file="$(mktemp)"

    if [ -f "${local_properties}" ]; then
        grep -Ev '^(flutter\.sdk|sdk\.dir)=' "${local_properties}" > "${tmp_file}" || true
    else
        : > "${tmp_file}"
    fi

    printf 'flutter.sdk=%s/flutter\n' "${FLUTTER_INSTALL_DIR}" >> "${tmp_file}"
    printf 'sdk.dir=%s\n' "${ANDROID_SDK_ROOT}" >> "${tmp_file}"
    mv "${tmp_file}" "${local_properties}"
fi

flutter pub get