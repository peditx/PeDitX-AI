#!/usr/bin/env bash
set -Eeuo pipefail
BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$HOME/.local/share/peditx-ai"
BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
ICONS="$HOME/.local/share/icons/hicolor/512x512/apps"
mkdir -p "$DEST/assets" "$DEST/assets/pwa-icons" "$DEST/web" "$BIN" "$APPS" "$ICONS"
install -m 0755 "$BASE/src/peditx_ai.py" "$DEST/peditx_ai.py"
install -m 0644 "$BASE/web/index.html" "$DEST/index.html"
install -m 0644 "$BASE/web/manifest.webmanifest" "$DEST/web/manifest.webmanifest"
install -m 0644 "$BASE/web/sw.js" "$DEST/web/sw.js"
install -m 0644 "$BASE/assets/peditx-ai.png" "$DEST/assets/peditx-ai.png"
install -m 0644 "$BASE/assets/pwa-icons/apple-touch-icon.png" "$DEST/assets/pwa-icons/apple-touch-icon.png"
install -m 0644 "$BASE/assets/pwa-icons/android-192.png" "$DEST/assets/pwa-icons/android-192.png"
install -m 0644 "$BASE/assets/pwa-icons/android-512.png" "$DEST/assets/pwa-icons/android-512.png"
install -m 0644 "$BASE/assets/peditx-ai.png" "$ICONS/peditx-ai.png"
cat > "$BIN/peditx-ai" <<'EOF'
#!/usr/bin/env bash
exec /usr/bin/python3 "$HOME/.local/share/peditx-ai/peditx_ai.py" "$@"
EOF
chmod 0755 "$BIN/peditx-ai"
cat > "$BIN/assist" <<'EOF'
#!/usr/bin/env bash
exec /usr/bin/python3 "$HOME/.local/share/peditx-ai/peditx_ai.py" --cli "$@"
EOF
chmod 0755 "$BIN/assist"
cat > "$APPS/peditx-ai.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=PeDitX-AI OS
Comment=Your configurable AI assistant for Linux OS
Exec=$BIN/peditx-ai
Icon=$ICONS/peditx-ai.png
Terminal=false
Categories=Utility;System;
Keywords=AI;Assistant;OS;System;
EOF
chmod 0644 "$APPS/peditx-ai.desktop"
printf 'Installed PeDitX-AI OS. Launch it from the applications menu or run: %s/peditx-ai\n' "$BIN"
