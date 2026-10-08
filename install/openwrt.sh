#!/bin/sh
set -eu
BASE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ "$(id -u)" -ne 0 ]; then
    echo "Run the OpenWrt installer as root over SSH." >&2
    exit 2
fi

DEST=/opt/peditx-ai
mkdir -p "$DEST" /usr/bin
AVAILABLE_KB=$(df -Pk /overlay | awk 'NR == 2 { print $4 }')
case "$AVAILABLE_KB" in
    ''|*[!0-9]*) echo "Could not read free space on /overlay; continuing and letting the package manager check." ;;
    *) printf 'Free space on /overlay (extroot) before dependency install: %s KiB\n' "$AVAILABLE_KB" ;;
esac

if command -v apk >/dev/null 2>&1; then
    apk update
    apk add python3-light python3-email python3-urllib python3-openssl python3-codecs ca-bundle
elif command -v opkg >/dev/null 2>&1; then
    opkg update
    opkg install python3-light python3-email python3-urllib python3-openssl python3-codecs ca-bundle
else
    echo "Could not find OpenWrt's apk or opkg package manager." >&2
    exit 2
fi

PYTHON=$(command -v python3 || true)
[ -n "$PYTHON" ] || { echo "Python 3 was not installed by the package manager." >&2; exit 1; }
if ! "$PYTHON" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)'; then
    echo "PeDitX-AI requires Python 3.10 or newer. Use an OpenWrt release whose package feed provides it." >&2
    exit 1
fi

cp "$BASE/src/peditx_ai.py" "$DEST/peditx_ai.py"
chmod 0644 "$DEST/peditx_ai.py"
cat > /usr/bin/assist <<EOF
#!/bin/sh
APP="$DEST/peditx_ai.py"
case "\${1:-}" in
    --configure|--models|--choose-model|--mode) exec "$PYTHON" "\$APP" "\$@" ;;
    *) exec "$PYTHON" "\$APP" --cli "\$@" ;;
esac
EOF
chmod 0755 /usr/bin/assist
printf '%s\n' "Installed the PeDitX-AI SSH/CLI profile in $DEST." "Run 'assist' over SSH. The GNOME desktop and browser service are not installed on OpenWrt." \
    "Remote Git sync requires Git to be installed separately; the base profile keeps that optional."
