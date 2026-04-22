#!/usr/bin/env bash
set -euo pipefail

readonly sdk_root="${ANDROID_SDK_ROOT}"
readonly flutter_extension="${FLUTTER_INSTALL_DIR}/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt"
readonly cmdline_tools_zip="/tmp/android-commandline-tools.zip"
readonly repository_xml_url="https://dl.google.com/android/repository/repository2-1.xml"
readonly sdkmanager="${sdk_root}/cmdline-tools/latest/bin/sdkmanager"

repository_xml="$(curl -fsSL "${repository_xml_url}")"
cmdline_tools_archive="$(printf '%s\n' "${repository_xml}" | grep -o 'commandlinetools-linux-[0-9]\+_latest.zip' | sort -uV | tail -n 1)"
compile_sdk="$(sed -n 's/.*val compileSdkVersion: Int = \([0-9][0-9]*\).*/\1/p' "${flutter_extension}" | head -n 1)"
ndk_version="$(sed -n 's/.*val ndkVersion: String = "\([^"]*\)".*/\1/p' "${flutter_extension}" | head -n 1)"
build_tools_package="$(printf '%s\n' "${repository_xml}" | grep -o "build-tools;${compile_sdk}\.[0-9.]*" | sort -uV | tail -n 1)"
platform_package="platforms;android-${compile_sdk}"

if [ -z "${cmdline_tools_archive}" ] || [ -z "${compile_sdk}" ] || [ -z "${ndk_version}" ] || [ -z "${build_tools_package}" ]; then
    echo "Failed to resolve Android SDK package versions" >&2
    echo "  cmdline_tools_archive=${cmdline_tools_archive:-<empty>}" >&2
    echo "  compile_sdk=${compile_sdk:-<empty>}" >&2
    echo "  ndk_version=${ndk_version:-<empty>}" >&2
    echo "  build_tools_package=${build_tools_package:-<empty>}" >&2
    exit 1
fi

if ! command -v java >/dev/null 2>&1; then
    echo "Java is required to run Android sdkmanager. Install a JDK in the devcontainer image before running this script." >&2
    exit 1
fi

echo "Installing Android SDK packages: ${platform_package}, ${build_tools_package}, ndk;${ndk_version}" >&2

readonly cmdline_tools_url="https://dl.google.com/android/repository/${cmdline_tools_archive}"

mkdir -p "${sdk_root}/cmdline-tools" /root/.android
touch /root/.android/repositories.cfg

curl -fsSL -o "${cmdline_tools_zip}" "${cmdline_tools_url}"
rm -rf "${sdk_root}/cmdline-tools/latest" "${sdk_root}/cmdline-tools/cmdline-tools"
unzip -q "${cmdline_tools_zip}" -d "${sdk_root}/cmdline-tools"
mv "${sdk_root}/cmdline-tools/cmdline-tools" "${sdk_root}/cmdline-tools/latest"
rm -f "${cmdline_tools_zip}"

set +o pipefail
yes | "${sdkmanager}" --sdk_root="${sdk_root}" --licenses >/dev/null
set -o pipefail
"${sdkmanager}" --sdk_root="${sdk_root}" \
    "platform-tools" \
    "${platform_package}" \
    "${build_tools_package}" \
    "ndk;${ndk_version}"