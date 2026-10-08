# Release and installer integration

`install.sh` detects the platform and dispatches to a separate GNOME, Debian headless, or OpenWrt CLI installer. OpenWrt currently has a source-tree bootstrap that installs dependencies through `opkg` or `apk`; a native OpenWrt feed package is still needed for a polished release. It must not call either desktop installation path. The root `linux-theme.sh` is maintained separately.

The future integration is a separate optional action at the end of the theme script: locate the sibling `PeDitX-AI/install.sh`, show the command or offer to run it, and leave theme setup successful if the user skips AI installation. Do not duplicate Python, HTML, icons, API credentials, or project source in the theme script.

The separate installation link must use the source folder beside `linux-theme.sh` and must not fetch an unreviewed remote script.
