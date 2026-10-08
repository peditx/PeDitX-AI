# Developing PeDitX-AI

PeDitX-AI is developed as a standalone project. Keep application code, web UI, assets, and release documentation here. The GNOME theme installer is a separate product and should only call this project's installer when the AI component is ready for release.

## Run from source

```bash
cd /media/peditx/HDD/Workspace/PeDitX-AI
PYTHONPATH=src python3 -m peditx_ai
```

The app uses only the Python standard library. It opens a browser on a loopback-only HTTP service. `install.sh` dispatches GNOME desktop, Debian-family headless, and OpenWrt SSH CLI installs to separate scripts. The OpenWrt bootstrap installs the needed Python modules through `opkg` or `apk`; a native feed package is still planned.

## Project layout

- `src/peditx_ai.py`: backend, local HTTP service, CLI, tools, memory, skills, and remote sync.
- `web/index.html`: English desktop UI.
- `assets/peditx-ai.png`: shared app icon and logo.
- `docs/`: design notes and release/integration decisions.
- `install.sh`: routes Debian-family desktop/headless installs and OpenWrt installs to separate platform scripts.
- `install/gnome-desktop.sh`: installs the GNOME desktop entry, browser UI, and user commands.
- `install/debian-headless.sh`: installs the user-local CLI for Debian-family headless systems such as Raspberry Pi OS Lite.
- `install/openwrt.sh`: installs the SSH CLI and minimal Python runtime modules using `opkg` or `apk`; PeDitXOS assumes extroot is mounted first. It reports free root/extroot space and lets the package manager decide whether the actual dependency set fits. It does not copy GNOME UI assets or launch a daemon. Configure an API using `assist --configure` over SSH.

## Portability direction

Read `docs/platform-support.md` before adding platform-specific behavior. Keep GNOME, systemd, Bash, and Debian package-manager assumptions out of the shared core. OpenWrt packaging must remain separate from `install/gnome-desktop.sh`; the current OpenWrt shell installer is a CLI bootstrap, not yet a native feed package. The web UI must remain loopback-only until remote authentication and transport protections are implemented.

## Release boundary

Do not copy application source into `linux-theme.sh`. Once development is declared complete, integrate a separate optional action that calls `PeDitX-AI/install.sh` next to the theme script. Until then, keep the existing one-click installer untouched.
