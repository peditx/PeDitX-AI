#!/bin/sh
set -eu

BASE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ -r /etc/openwrt_release ] || [ -r /etc/openwrt_version ]; then
    printf '%s\n' "Detected OpenWrt/PeDitXOS; using the apk or opkg CLI installer."
    exec "$BASE/install/openwrt.sh" "$@"
fi

if command -v apt-get >/dev/null 2>&1; then
    printf '%s\n' "Detected Debian-family Linux; using apt dependencies."
    if command -v gnome-shell >/dev/null 2>&1; then
        "$BASE/install/apt-dependencies.sh" desktop
        exec bash "$BASE/install/gnome-desktop.sh" "$@"
    fi
    "$BASE/install/apt-dependencies.sh" headless
    exec "$BASE/install/debian-headless.sh" "$@"
fi

printf '%s\n' "Supported installation targets are Debian-family Linux with apt and OpenWrt with opkg/apk." \
    "See: $BASE/docs/platform-support.md" >&2
exit 2
