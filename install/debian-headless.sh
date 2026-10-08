#!/bin/sh
set -eu
BASE=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DEST=${XDG_DATA_HOME:-"$HOME/.local/share"}/peditx-ai
BIN=${HOME}/.local/bin
mkdir -p "$DEST/assets" "$BIN"
cp "$BASE/src/peditx_ai.py" "$DEST/peditx_ai.py"
cp "$BASE/web/index.html" "$DEST/index.html"
cp "$BASE/assets/peditx-ai.png" "$DEST/assets/peditx-ai.png"
chmod 0644 "$DEST/peditx_ai.py" "$DEST/index.html" "$DEST/assets/peditx-ai.png"
cat > "$BIN/assist" <<'EOF'
#!/bin/sh
APP="${XDG_DATA_HOME:-$HOME/.local/share}/peditx-ai/peditx_ai.py"
case "${1:-}" in
    --configure|--models|--choose-model|--mode) exec "${PYTHON:-python3}" "$APP" "$@" ;;
    *) exec "${PYTHON:-python3}" "$APP" --cli "$@" ;;
esac
EOF
chmod 0755 "$BIN/assist"
printf 'Installed PeDitX-AI CLI. Add %s to PATH if needed, then run: assist\n' "$BIN"
