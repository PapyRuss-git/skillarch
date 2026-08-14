# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## SkillArch Overview

SkillArch is a Linux penetration testing and cybersecurity distribution built on CachyOS (Arch-based). It provides a complete environment with offensive security tools, development tools, and a choice between two window manager setups:
- **i3-gaps** (X11) - Stable, mature, widely supported
- **Hyprland** (Wayland) - Modern, smooth animations, cutting-edge

> **Note:** `make install` now persists a WM choice in `~/.config/skillarch/wm-choice`. Hyprland uses Quickshell as the default bar (installed automatically); Waybar is also installed as an alternative and can be selected via `ska-bar-toggle`.

## Key Commands

### Installation and Management
- `make install` - Full SkillArch installation (requires sudo)
- `make help` - Show all available make targets
- `make update` - Update SkillArch from upstream (requires clean git state)
- `ska-update-simple` - Simple update helper (pull + install)
- `ska-update-advanced` - Advanced update helper for forked repos

### Component Installation
- `make install-base` - Install base packages and setup
- `make install-cli-tools` - Install CLI tools and development environment
- `make install-shell` - Install zsh, oh-my-zsh, and shell configuration
- `make install-docker` - Install and configure Docker
- `make install-gui` - Install GUI components for the currently selected WM
- `make install-quickshell` - Install Quickshell bar (installed by default on Hyprland; run standalone to reinstall)
- `make install-gui-tools` - Install GUI applications
- `make install-offensive` - Install penetration testing tools
- `make install-wordlists` - Install security wordlists
- `make install-hardening` - Install security hardening tools

### Docker Commands
- `make docker-build` - Build lite Docker image
- `make docker-build-full` - Build full Docker image with GUI (legacy, installs both WMs)
- `make docker-build-full-i3` - Build full Docker image with i3 only
- `make docker-build-full-hyprland` - Build full Docker image with Hyprland only
- `make docker-run` - Run lite Docker container
- `make docker-run-full` - Run full Docker container with X11 (legacy)
- `make docker-run-full-i3` - Run full Docker container with i3 and X11
- `make docker-run-full-hyprland` - Run full Docker container with Hyprland and Wayland

### Helper Commands
- `ska-help-aliases` - Fuzzy search through available aliases
- `ska-help-bindings` - Fuzzy search through WM key bindings (i3 or Hyprland)
- `ska-help-packages` - Fuzzy search through installed packages
- `ska-sudo-unlock` - Unlock user after failed sudo attempts
- `ska-wm-info` - Display current window manager info
- `ska-bar-waybar` - Switch to Waybar (Hyprland)
- `ska-bar-quickshell` - Switch to Quickshell bar (Hyprland)
- `ska-bar-toggle` - Cycle between Waybar and Quickshell
- `ska-bar-info` - Show current bar choice

## Architecture and Structure

### Modular Installation Pipeline
The Makefile follows a strict dependency chain ensuring proper component ordering:
```
install: install-base → install-cli-tools → install-shell → install-docker → install-gui → install-gui-tools → install-offensive → install-wordlists → install-hardening
```

**Key architectural principles:**
- Each component can be installed independently
- All targets require `sanity-check` (must run from `/opt/skillarch` with sudo access)
- Progressive complexity: base system → CLI → GUI → specialized security tools
- Cleanup performed automatically after each major installation phase

### Directory Structure
- `/opt/skillarch/` - Main installation directory
- `/opt/skillarch/config/` - Configuration files for all applications  
- `/opt/skillarch/assets/` - Images and assets
- `/opt/lists/` - Security wordlists and payloads organized by purpose
- `/opt/[tool-name]/` - Cloned security tools (chisel, phpggc, CloudFlair, etc.)

### Configuration Management System
Centralized configuration with atomic symlink operations from `/opt/skillarch/config/`:

**Common Configs** (Both WMs):
- `config/zshrc` → `~/.zshrc`
- `config/vimrc` → `~/.vimrc`
- `config/tmux.conf` → `~/.tmux.conf`
- `config/kitty/kitty.conf` → `~/.config/kitty/kitty.conf`
- `config/nvim/init.lua` → `~/.config/nvim/init.lua`
- `config/rofi/` → `~/.config/rofi/`

**i3-specific Configs** (X11):
- `config/i3/config` → `~/.config/i3/config`
- `config/polybar/` → `~/.config/polybar/`
- `config/picom.conf` → `~/.config/picom.conf`
- `config/xorg.conf.d/30-touchpad.conf` → `/etc/X11/xorg.conf.d/30-touchpad.conf`

**Hyprland-specific Configs** (Wayland):
- `config/hypr/hyprland.lua` → `~/.config/hypr/hyprland.lua` (Lua config, Hyprland 0.55+; hyprlang `.conf` is deprecated)
- `config/hypr/hyprland-desktop.lua` or `config/hypr/hyprland-vm.lua` → `~/.config/hypr/hyprland-mode.lua` (mode overrides, per `HYPR_MODE`)
- `~/.config/hypr/monitors.lua` (local, untracked) — optional multi-monitor overrides sourced by `hyprland.lua`
- `config/hypr/hyprlock.conf` → `~/.config/hypr/hyprlock.conf`
- `config/hypr/hypridle.conf` → `~/.config/hypr/hypridle.conf`
- `config/hypr/hyprpaper.conf` → `~/.config/hypr/hyprpaper.conf`
- `config/hypr/waybar/` → `~/.config/waybar/`
- `config/hypr/quickshell/` → `~/.config/quickshell/` (C++/Qt6/QML bar, installed by default on Hyprland)
- `config/hypr/scripts/` → `~/.config/hypr/scripts/` (bar launcher, etc.)
- `config/hypr/swaync/` → `~/.config/swaync/`
- `config/hypr/clipse/` → `~/.config/clipse/`
- `config/hypr/xdg-desktop-portal/` → `~/.config/xdg-desktop-portal/`

**Backup strategy**: Existing configs moved to `.skabak` files before symlinking

### Multi-Layered Package Management
**System Level** (`pacman`/`yay`):
- Core packages via pacman with parallel downloads enabled  
- AUR packages via yay with chaotic-aur repository configured
- Optimized builds in tmpfs (`/dev/shm/makepkg`) for performance

**Language-Specific** (`mise`):
- Version management for Go, Rust, Node.js, Python, PHP, Terraform
- Go security tools installed via `mise exec -- go install`
- Isolated environments prevent version conflicts

**Python Isolation** (`pipx`):
- Security tools in isolated virtual environments: sqlmap, dirsearch, exegol, semgrep
- Setuptools injected to handle dependency issues

**Security Ecosystem**:
- **PDTM**: ProjectDiscovery tools (nuclei, subfinder, httpx, dnsx)
- **Direct clones**: Custom tools in `/opt/[tool]/` for easy updates
- **Wordlists**: Curated collections (rockyou, SecLists, PayloadsAllTheThings) in `/opt/lists/`

### Docker Multi-Stage Architecture
**Multi-tier build strategy**:
- **Dockerfile-lite**: Base CLI environment (cachyos → hacker user → base/cli/shell/offensive)
- **Dockerfile-full**: Legacy GUI image extending lite (docker/gui/gui-tools/wordlists/hardening) - installs both i3 and Hyprland (not recommended due to package conflicts)
- **Dockerfile-full-i3**: Extends lite with i3 GUI components only (docker/gui/gui-tools/wordlists/hardening) - sets WM_CHOICE=i3
- **Dockerfile-full-hyprland**: Extends lite with Hyprland GUI components only (docker/gui/gui-tools/wordlists/hardening) - sets WM_CHOICE=hyprland

**Build process**:
Each full-* image sets the WM choice via `~/.config/skillarch/wm-choice` before running `make install-gui`, which triggers the conditional installation logic:
- `install-gui` → `install-gui-common` → `install-gui-wm` → `install-gui-{i3|hyprland}`

**Security model**: NOPASSWD sudo only during installation, reverted to password-required afterward

## Development Environment

### Shell Environment
- **Default Shell**: zsh with oh-my-zsh framework  
- **Theme**: af-magic (not Powerlevel10k)
- **Key Plugins**: fzf (fuzzy finding), mise (language versions), docker, terraform, npm, zsh-autosuggestions, zsh-syntax-highlighting
- **Aliases**: 200+ organized aliases in `config/aliases` (sourced by zshrc)
- **Helper Commands**: `ska-*` prefixed commands for system management

### Multi-Desktop Environment Support

SkillArch supports two distinct window manager setups selected at install time via `WM_CHOICE`.

**i3-gaps (X11 Stack)**
- **Terminal**: Kitty with Everforest theme
- **Window Manager**: i3-gaps with AZERTY layout bindings
- **Status Bar**: Polybar with system monitoring
- **Launcher**: Rofi
- **Compositor**: Picom (auto-disabled in hypervisor environments)
- **Screenshots**: Flameshot
- **Lock Screen**: i3lock-fancy
- **Clipboard**: xclip

**Hyprland (Wayland Stack)**
- **Terminal**: Kitty with Everforest theme
- **Compositor**: Hyprland with GNOME coexistence
- **Status Bar**: Quickshell (default, C++/Qt6/QML) or Waybar (both installed; toggle via `ska-bar-toggle`)
- **Launcher**: Rofi (Wayland mode)
- **Notifications**: Dunst
- **Background**: Hyprpaper
- **Screenshots**: Grim + Slurp
- **Lock Screen**: Hyprlock
- **Clipboard**: wl-clipboard + Clipse
- **Idle Management**: Hypridle
- **Bar Switching**: `ska-bar-toggle` to cycle between Waybar and Quickshell

**Common Components** (Both Environments)
- **File Manager**: Nautilus (GNOME)
- **Settings**: GNOME Control Center
- **Audio Control**: Pavucontrol
- **Display Config**: arandr (i3) / Hyprland built-in (Hyprland)

### Editor Configuration
- **Neovim**: LazyVim starter configuration with custom `init.lua`
- **VSCode**: Extensions auto-installed from `config/extensions.txt`
- **Vim**: Custom configuration in `config/vimrc`

## Important Notes

### Git Workflow
- Main branch is `main`
- Repository should be kept clean for updates
- Users can fork and maintain custom configurations
- Never commit secrets or sensitive information

### Docker Usage
- **Lite image**: CLI tools only (no GUI) - ~2GB
- **Full image** (legacy): Includes GUI tools and wordlists (installs both i3 and Hyprland) - ~5GB - not recommended due to package conflicts
- **Full-i3 image**: Includes i3 GUI environment, tools and wordlists - ~4GB
- **Full-hyprland image**: Includes Hyprland GUI environment, tools and wordlists - ~4GB
- X11 forwarding supported for i3 images
- Wayland support for Hyprland images (requires host Wayland compositor)

### Multi-Monitor Setup
- Use `arandr` for display configuration
- Save layout as `~/.screenlayout/arandr-main-layout.sh`
- Auto-apply with `~/.xprofile`

### Security Considerations
- OpenSnitch for egress firewall (opt-in)
- UFW for ingress firewall
- Docker bypasses UFW rules by default
- User added to docker group (logout required)

### VM/VirtualBox Notes
- VirtualBox guest utilities available via `ska-vbox-install-guestutils`
- Picom disabled in hypervisor environments for performance
- Recommended to use GNOME Boxes instead of VirtualBox

## File Locations

### Configuration Files
- Main aliases: `config/aliases`
- **i3 configuration**: `config/i3/config`, `config/polybar/`, `config/picom.conf`, `config/xorg.conf.d/`
- **Hyprland configuration**: `config/hypr/` (contains hyprland.lua, hyprland-desktop.lua, hyprland-vm.lua — Lua format, Hyprland 0.55+ — plus hyprlock.conf, hypridle.conf, hyprpaper.conf, waybar/, swaync/, clipse/, xdg-desktop-portal/; hypr* tools keep hyprlang .conf)
- **Common configs**: `config/kitty/`, `config/rofi/`, `config/nvim/`, `config/zshrc`, `config/vimrc`, `config/tmux.conf`
- VSCode extensions: `config/extensions.txt`
- Chrome extensions list: `config/chrome-extensions.lst`

### Important Paths
- Wordlists: `/opt/lists/`
- Custom tools: `/opt/[tool-name]/`
- Long-lived data: `/DATA/`
- Trash: `/.Trash/`

## Update and Maintenance Workflows

### Two-Tier Update Strategy
**Simple Updates** (`ska-update-simple`):
- For users wanting upstream changes without customization
- Requires clean git state
- Workflow: `cd /opt/skillarch && git pull && make install`

**Advanced Updates** (`ska-update-advanced`):  
- For users with forked repositories and custom modifications
- Merges upstream changes while preserving customizations
- Handles git conflicts and drift analysis

### Maintenance and Cleanup
- **`make clean`**: Removes caches, logs, temporary files
- **Package hygiene**: Orphan removal, cache clearing via `paccache`, `yay -Yc`
- **Docker cleanup**: System prune, image cleanup
- **Log management**: Journal vacuum, log truncation

## Testing and Validation
No specific test framework - SkillArch is primarily a system configuration and tool collection. Validation through:
- Successful modular component installation
- Docker multi-stage builds (lite/full images)
- CI/CD security scanning (Semgrep, Trivy, Gitleaks, TruffleHog)  
- Manual testing of desktop environments and tool functionality

## Security Architecture
- **OpenSnitch**: Egress firewall (opt-in)
- **UFW**: Ingress firewall (Docker bypasses by default)
- **Docker group**: Grants root-equivalent access (security consideration)
- **Secret management**: Never commit credentials; use environment variables
- **Multi-layer scanning**: Automated security checks in CI/CD pipeline

## Everforest Theme Color Palette

### Hard Dark Variant
**Foreground/Text:**
- Primary: `#D3C6AA`
- Secondary: `#9DA9A0`
- Dimmed: `#7A8478`

**Background:**
- Dim: `#1E2326`
- Base: `#272E33`
- Surface: `#2E383C`
- Float: `#374145`
- Sidebar: `#414B50`
- Selection: `#4F5B58`

**Accent Colors:**
- Red: `#E67E80`
- Orange: `#E69875` 
- Yellow: `#DBBC7F`
- Green: `#A7C080`
- Blue: `#7FBBB3`
- Aqua: `#83C092`
- Purple: `#D699B6`

**Background Variants:**
- Red Background: `#4C3743`
- Visual Background: `#493B40`
- Yellow Background: `#45443C`
- Green Background: `#3C4841`
- Blue Background: `#384B55`

### Soft Light Variant
**Foreground/Text:**
- Primary: `#5C6A72`
- Secondary: `#829181`
- Dimmed: `#A6B0A0`

**Background:**
- Dim: `#F2EFDF`
- Base: `#FFFBEF`
- Surface: `#F8F5E4`
- Float: `#F2EFDF`
- Sidebar: `#EFEBD4`
- Selection: `#BEC5B2`

**Accent Colors:**
- Red: `#F85552`
- Orange: `#F57D26`
- Yellow: `#DFA000`
- Green: `#8DA101`
- Blue: `#3A94C5`
- Aqua: `#35A77C`
- Purple: `#DF69BA`

**Background Variants:**
- Red Background: `#FFE7DE`
- Visual Background: `#F0F2D4`
- Yellow Background: `#FEF2D5`
- Green Background: `#F3F5D9`
- Blue Background: `#ECF5ED`
