# Platform support strategy

PeDitX-AI targets different deployment profiles rather than pretending every Linux device is a GNOME desktop.

## Deployment profiles

| Target | Intended experience | Installer/package path |
| --- | --- | --- |
| Linux desktop (Mint, Ubuntu, Debian) | Desktop window, local browser UI, CLI | `apt` dependencies; GNOME desktop integration when GNOME is present |
| Raspberry Pi OS / Ubuntu on Raspberry Pi | Same desktop experience when a desktop is installed; CLI on Lite | Debian-family `apt`; desktop components are optional |
| OpenWrt router / PeDitXOS | SSH CLI bootstrap profile | `apk` packages on newer releases or `opkg` with `.ipk` packages on older releases; extroot expected |

The application core, CLI, browser interface, and operating-system integrations should remain separate. Linux desktop and headless profiles use OpenSSH for outbound SSH actions (the host must already be in known_hosts); install `openssh-client` on Debian-family systems. GIO SMB mounting is a desktop-only capability that uses the active session and system keyring. On headless Linux and OpenWrt, mount SMB through the OS first and set its mount path as Workspace. The current OpenWrt bootstrap does not yet provision or guarantee an outbound SSH client compatible with PeDitX-AI’s verified-host-key options, and it does not provide a GIO SMB mounter. Treat outbound SSH and direct SMB mount as unavailable on OpenWrt until its adapter and package dependencies are implemented; an OS-mounted share can still be selected if available. GNOME launchers and desktop integration belong in `install/gnome-desktop.sh`; Debian-family headless systems use `install/debian-headless.sh`; OpenWrt uses `install/openwrt.sh`. The current Python requirement is 3.10 or newer. The core must not require GNOME, `xdg-open`, Bash, `apt`, or systemd to start.

## OpenWrt limits and security

OpenWrt is an embedded router OS, not a desktop environment. The full GNOME experience does not apply there. The current bootstrap installer uses the router's package manager only for dependencies, then installs the app files and SSH CLI locally. PeDitXOS deployments are expected to have extroot mounted before installation, so app files, Python dependencies, and user data share the writable extroot-backed root filesystem. OpenWrt 25.12 and newer use `apk`; 24.10 and older use `opkg`. A future release package should be built through OpenWrt's package build system for the target release and architecture, with a separate procd service only if a safe headless service mode is implemented.

Python modules are split into separate OpenWrt packages, so “standard library only” does not mean every import is present after installing the small Python runtime. The CLI bootstrap installs `python3-light`, `python3-email`, `python3-urllib`, `python3-openssl`, `python3-codecs`, and CA certificates. The CLI defers importing the web server, so it does not install the web-only logging module or any GNOME UI files. These names must be available in the device's configured package feeds. OpenWrt has an official Python package feed and architecture-specific builds. PeDitXOS assumes extroot, so package and app storage should land on that volume. The installer reports current free space but does not impose an arbitrary minimum; the package manager checks the actual package set. A Raspberry Pi running OpenWrt uses the same OpenWrt installer and CLI profile.

The current web server binds to loopback and generates a one-launch bearer token. That is appropriate for a local desktop browser, but is not yet a remote router UI; the OpenWrt bootstrap does not install or launch it. Do not expose it on a LAN or WAN until persistent authentication, safe secret provisioning, TLS or a trusted TLS proxy, and an explicit network-access setting are implemented. The SSH CLI runs as the account invoking it. On common OpenWrt setups that is root, so full access would mean root access and must remain off unless explicitly selected.

## Implementation sequence

1. Freeze the product contract and delivery gates in [architecture.md](architecture.md), including identity, sessions, memory, skills, and permission behavior.
2. Split the current Python prototype into agent, provider, policy, storage, tools, CLI, and desktop service modules while keeping the existing desktop experience as the behavior reference.
3. Harden the local policy engine before adding more powerful tools: structured commands, symlink-safe paths, per-call approval, and identical enforcement for CLI and desktop.
4. Prototype Lua for the OpenWrt SSH profile and compare working HTTPS/API behavior, tool-call parity, private state handling, dependencies, and installed footprint on supported feeds. Record whether the product will use Python everywhere, a split Lua/Python runtime, or Lua everywhere before a broad rewrite.
5. Build a native OpenWrt package for supported releases/architectures with dependencies declared in the package metadata. Keep the bootstrap installer for development only. Add procd only when a specific background service feature requires it.
6. Keep SSH CLI as the first OpenWrt experience. Design a LuCI integration only after authentication, CSRF protection, access-mode enforcement, and TLS integration with uHTTPd are implemented.
7. Keep desktop integration, Raspberry Pi desktop/headless support, and OpenWrt packaging independently installable. The theme installer remains outside this project until the AI release is ready.

## Support claims

“Runs on Linux” is not sufficient evidence of OpenWrt compatibility. A target becomes supported only after its package builds for the target feed, installs on representative hardware, starts and stops through its service manager, and can use the core and CLI without desktop packages. Desktop and remote browser features must be documented separately.
