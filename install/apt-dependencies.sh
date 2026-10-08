#!/bin/sh
set -eu

MODE=${1:-headless}
case "$MODE" in
    headless) PACKAGES="python3 ca-certificates openssh-client" ;;
    desktop) PACKAGES="python3 ca-certificates xdg-utils poppler-utils openssh-client gvfs-backends" ;;
    *) printf 'Usage: %s [headless|desktop]\n' "$0" >&2; exit 2 ;;
esac

if ! command -v apt-get >/dev/null 2>&1; then
    echo "This dependency installer requires apt-get." >&2
    exit 2
fi

NEED_INSTALL=0
for package in $PACKAGES; do
    if ! dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null | grep -qx installed; then
        NEED_INSTALL=1
        break
    fi
done
[ "$NEED_INSTALL" -eq 1 ] || exit 0

if [ "$(id -u)" -eq 0 ]; then
    APT="apt-get"
else
    command -v sudo >/dev/null 2>&1 || { echo "Install sudo or run this setup with administrator privileges." >&2; exit 2; }
    APT="sudo apt-get"
fi

# shellcheck disable=SC2086
$APT update
# shellcheck disable=SC2086
$APT install -y $PACKAGES

if ! python3 -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
    echo "PeDitX-AI requires Python 3.10 or newer; this distribution provides an older Python." >&2
    exit 1
fi
