.ONESHELL:
.PHONY: help

help: ## Show this help message
	@echo 'Welcome to SkillArch! 🌹'
	@echo ''
	@echo 'Usage: make [target]'
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-18s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ''

install: prompt-wm-choice install-base install-cli-tools install-shell install-docker install-gui install-gui-tools install-offensive install-wordlists install-hardening clean ## Install SkillArch
	@echo "You are all set up! Enjoy ! 🌹"

sanity-check:
	set -x
	@# Ensure we are in /opt/skillarch or /opt/skillarch-original (maintainer only)
	@[ "$$(pwd)" != "/opt/skillarch" ] && [ "$$(pwd)" != "/opt/skillarch-original" ] && echo "You must be in /opt/skillarch or /opt/skillarch-original to run this command" && exit 1
	@sudo id || (echo "Error: sudo access is required" ; exit 1)

# Window Manager Choice Variables (persisted in ~/.config/skillarch/)
SKA_CONFIG_DIR := $(HOME)/.config/skillarch
WM_CHOICE := $(shell cat $(HOME)/.config/skillarch/wm-choice 2>/dev/null || echo "")
HYPR_MODE := $(shell cat $(HOME)/.config/skillarch/hypr-mode 2>/dev/null || echo "desktop")

.PHONY: validate-wm-choice
validate-wm-choice: ## Validate that WM_CHOICE is set correctly
	@if [ -z "$(WM_CHOICE)" ]; then \
		echo "❌ ERROR: WM_CHOICE not set. Run 'make prompt-wm-choice' first."; \
		exit 1; \
	fi
	@if [ "$(WM_CHOICE)" != "i3" ] && [ "$(WM_CHOICE)" != "hyprland" ]; then \
		echo "❌ ERROR: Invalid WM_CHOICE '$(WM_CHOICE)'. Must be 'i3' or 'hyprland'."; \
		exit 1; \
	fi
	@echo "✅ WM_CHOICE validated: $(WM_CHOICE)"
	@if [ "$(WM_CHOICE)" = "hyprland" ]; then \
		echo "   Hyprland mode: $(HYPR_MODE)"; \
	fi

.PHONY: prompt-wm-choice
prompt-wm-choice: ## Prompt user to choose window manager
	@echo "════════════════════════════════════════════════════════"
	@echo "  SkillArch Window Manager Selection"
	@echo "════════════════════════════════════════════════════════"
	@echo ""
	@echo "Choose your window manager:"
	@echo "  1) i3-gaps (X11)                - Stable, mature, low resource usage"
	@echo "  2) Hyprland (Wayland - Desktop) - Modern, animations, blur, eye candy"
	@echo "  3) Hyprland (Wayland - VM)      - Optimized for VMs (no animations/blur)"
	@echo ""
	@mkdir -p $(SKA_CONFIG_DIR)
	@read -p "Enter choice [1-3]: " choice; \
	case $$choice in \
		1) echo "i3" > $(SKA_CONFIG_DIR)/wm-choice ; rm -f $(SKA_CONFIG_DIR)/hypr-mode ;; \
		2) echo "hyprland" > $(SKA_CONFIG_DIR)/wm-choice ; echo "desktop" > $(SKA_CONFIG_DIR)/hypr-mode ;; \
		3) echo "hyprland" > $(SKA_CONFIG_DIR)/wm-choice ; echo "vm" > $(SKA_CONFIG_DIR)/hypr-mode ;; \
		*) echo "❌ Invalid choice. Aborting."; exit 1 ;; \
	esac
	@echo ""
	@echo "✅ Selected: $$(cat $(SKA_CONFIG_DIR)/wm-choice)"
	@[ -f $(SKA_CONFIG_DIR)/hypr-mode ] && echo "   Hyprland mode: $$(cat $(SKA_CONFIG_DIR)/hypr-mode)" || true
	@echo ""

install-base: sanity-check ## Install base packages
	# Clean up, Update, Basics
	sudo sed -e "s#.*ParallelDownloads.*#ParallelDownloads = 10#g" -i /etc/pacman.conf
	echo 'BUILDDIR="/dev/shm/makepkg"' | sudo tee /etc/makepkg.conf.d/00-skillarch.conf
	sudo cachyos-rate-mirrors # Increase install speed & Update repos
	yes|sudo pacman -Scc
	yes|sudo pacman -Syu
	yes|sudo pacman -S --noconfirm --needed git vim tmux wget curl archlinux-keyring
	sudo pacman-key --init
	sudo pacman-key --populate archlinux
	sudo pacman-key --refresh-keys

	# Add chaotic-aur to pacman
	curl -sS "https://keyserver.ubuntu.com/pks/lookup?op=get&options=mr&search=0x3056513887B78AEB" | sudo pacman-key --add -
	sudo pacman-key --lsign-key 3056513887B78AEB
	sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
	sudo pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

	# Ensure chaotic-aur is present in /etc/pacman.conf
	grep -vP '\[chaotic-aur\]|Include = /etc/pacman.d/chaotic-mirrorlist' /etc/pacman.conf | sudo tee /etc/pacman.conf > /dev/null
	echo -e '[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | sudo tee -a /etc/pacman.conf > /dev/null
	yes|sudo pacman -Syu

	# Long Lived DATA & trash-cli Setup
	[ ! -d /DATA ] && sudo mkdir -pv /DATA && sudo chown "$$USER:$$USER" /DATA && sudo chmod 770 /DATA
	[ ! -d /.Trash ] && sudo mkdir -pv /.Trash && sudo chown "$$USER:$$USER" /.Trash && sudo chmod 770 /.Trash && sudo chmod +t /.Trash
	make clean

install-cli-tools: sanity-check ## Install system packages
	yes|sudo pacman -S --noconfirm --needed base-devel bison bzip2 ca-certificates cloc cmake dos2unix expect ffmpeg foremost gdb gnupg htop bottom hwinfo icu inotify-tools iproute2 jq llvm lsof ltrace make mlocate mplayer ncurses net-tools ngrep nmap openssh openssl parallel perl-image-exiftool pkgconf python-virtualenv re2c readline ripgrep rlwrap socat gnu-netcat sqlite sshpass tmate tor traceroute trash-cli tree unzip vbindiff xclip xz yay zip veracrypt git-delta viu xsv asciinema htmlq neovim glow jless websocat superfile gron eza fastfetch bat sysstat cronie starship
	sudo ln -sf /usr/bin/bat /usr/local/bin/batcat
	bash -c "$$(curl -fsSL https://gef.blah.cat/sh)"
	# eza doesn't need the libgit2 workaround that exa required
	# nvim config
	[ ! -d ~/.config/nvim ] && git clone --depth=1 https://github.com/LazyVim/starter ~/.config/nvim
	[ -f ~/.config/nvim/init.lua ] && [ ! -L ~/.config/nvim/init.lua ] && mv ~/.config/nvim/init.lua ~/.config/nvim/init.lua.skabak
	ln -sf /opt/skillarch/config/nvim/init.lua ~/.config/nvim/init.lua
	nvim --headless +"Lazy! sync" +qa >/dev/null # Download and update plugins

	# Install pipx & tools
	yay --noconfirm --needed -S python-pipx
	pipx ensurepath
	for package in argcomplete bypass-url-parser dirsearch exegol pre-commit sqlmap wafw00f yt-dlp semgrep; do pipx install -q "$$package" && pipx inject -q "$$package" setuptools; done

	# Install mise and all php-build dependencies
	yes|sudo pacman -S --noconfirm --needed mise libedit libffi libjpeg-turbo libpcap libpng libxml2 libzip postgresql-libs php-gd
	# mise self-update # Currently broken, wait for upstream fix, pinged on 17/03/2025
	for i in $$(seq 1 30); do command -v mise >/dev/null 2>&1 && break || sleep 1; done
	command -v mise >/dev/null 2>&1 || { echo "ERROR: mise not found after install"; exit 1; }
	for package in usage pdm rust terraform golang python nodejs; do mise use -g "$$package@latest" && mise exec -- true || { echo "ERROR: mise use $$package failed"; exit 1; }; done
	mise exec -- go env -w "GOPATH=/home/$$USER/.local/go"
	make clean

install-shell: sanity-check ## Install shell packages
	# Install and Configure zsh and oh-my-zsh
	yes|sudo pacman -S --noconfirm --needed zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search zsh-theme-powerlevel10k
	[ ! -d ~/.oh-my-zsh ] && sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	[ -f ~/.zshrc ] && [ ! -L ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.skabak
	ln -sf /opt/skillarch/config/zshrc ~/.zshrc
	[ ! -d ~/.oh-my-zsh/plugins/zsh-completions ] && git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions
	[ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ] && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
	[ ! -d ~/.oh-my-zsh/plugins/zsh-syntax-highlighting ] && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
	[ ! -d ~/.ssh ] && mkdir ~/.ssh && chmod 700 ~/.ssh # Must exist for ssh-agent to work
	for plugin in colored-man-pages docker extract fzf mise npm terraform tmux zsh-autosuggestions zsh-completions zsh-syntax-highlighting ssh-agent; do zsh -c "source ~/.zshrc && omz plugin enable $$plugin || true"; done
	make clean

	# Install and configure fzf, tmux, vim
	[ ! -d ~/.fzf ] && git clone --depth=1 https://github.com/junegunn/fzf ~/.fzf && ~/.fzf/install --all
	[ -f ~/.tmux.conf ] && [ ! -L ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.skabak
	ln -sf /opt/skillarch/config/tmux.conf ~/.tmux.conf
	[ -f ~/.vimrc ] && [ ! -L ~/.vimrc ] && mv ~/.vimrc ~/.vimrc.skabak
	ln -sf /opt/skillarch/config/vimrc ~/.vimrc
	# Set the default user shell to zsh
	sudo chsh -s /usr/bin/zsh "$$USER" # Logout required to be applied

install-docker: sanity-check ## Install docker
	yes|sudo pacman -S --noconfirm --needed docker docker-compose
	# It's a desktop machine, don't expose stuff, but we don't care much about LPE
	# Think about it, set "alias sudo='backdoor ; sudo'" in userland and voila. OSEF!
	sudo usermod -aG docker "$$USER" # Logout required to be applied
	sleep 1 # Prevent too many docker socket calls and security locks
	# Do not start services in docker
	[ ! -f /.dockerenv ] && sudo systemctl enable --now docker
	make clean

.PHONY: install-gui-common
install-gui-common: sanity-check ## Install common GUI packages (X11 + Wayland compatible)
	# Common terminal & fonts
	yes|sudo pacman -S --noconfirm --needed \
		kitty \
		ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji \
		ttf-jetbrains-mono-nerd ttf-firacode-nerd ttf-meslo-nerd

	# Common launcher (works on both X11 and Wayland)
	yes|sudo pacman -S --noconfirm --needed rofi

	# Common audio & brightness
	yes|sudo pacman -S --noconfirm --needed pavucontrol brightnessctl

	# DDC/CI driver for external monitor brightness control (KDE-like behavior)
	# After reboot, brightnessctl will control ALL monitors (laptop + external) simultaneously
	yay --noconfirm --needed -S ddcci-driver-linux-dkms
	echo "ddcci" | sudo tee /etc/modules-load.d/ddcci.conf
	sudo modprobe ddcci || true
	# Ensure i2c group exists for DDC/CI access
	getent group i2c > /dev/null || sudo groupadd i2c
	sudo usermod -aG i2c "$$USER" || true

	# Common file manager & utilities
	yes|sudo pacman -S --noconfirm --needed nautilus file-roller arandr

	# Common GNOME components (X11/Wayland compatible)
	yes|sudo pacman -S --noconfirm --needed \
		gnome-control-center \
		gnome-bluetooth-3.0 \
		gnome-keyring \
		gnome-settings-daemon \
		bluez bluez-utils

	# Common network manager
	yes|sudo pacman -S --noconfirm --needed nm-connection-editor

	# Enable Bluetooth service (do not start services in docker)
	[ ! -f /.dockerenv ] && sudo systemctl enable --now bluetooth.service

	# Dark mode preference
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

	# kitty config (common)
	[ ! -d ~/.config/kitty ] && mkdir -p ~/.config/kitty
	[ -f ~/.config/kitty/kitty.conf ] && [ ! -L ~/.config/kitty/kitty.conf ] && mv ~/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf.skabak
	ln -sf /opt/skillarch/config/kitty/kitty.conf ~/.config/kitty/kitty.conf

	# rofi config (common)
	[ ! -d ~/.config/rofi ] && mkdir -p ~/.config/rofi
	[ -f ~/.config/rofi/config.rasi ] && [ ! -L ~/.config/rofi/config.rasi ] && mv ~/.config/rofi/config.rasi ~/.config/rofi/config.rasi.skabak
	ln -sf /opt/skillarch/config/rofi/config.rasi ~/.config/rofi/config.rasi
	make clean

.PHONY: install-gui-i3
install-gui-i3: sanity-check ## Install i3 window manager (X11)
	[ ! -f /etc/machine-id ] && sudo systemd-machine-id-setup

	# i3 window manager packages
	yes|sudo pacman -S --noconfirm --needed \
		i3-gaps i3blocks i3lock i3lock-fancy-git i3status \
		polybar picom dmenu

	# X11 utilities
	yes|sudo pacman -S --noconfirm --needed \
		feh flameshot xss-lock \
		xorg-server xorg-xinit xorg-xrandr xorg-xhost \
		xclip xdotool

	# X11 portal & polkit
	yes|sudo pacman -S --noconfirm --needed xdg-desktop-portal-gtk polkit-gnome

	# AUR packages
	yay --noconfirm --needed -S rofi-power-menu i3-battery-popup-git

	# i3 config
	[ ! -d ~/.config/i3 ] && mkdir -p ~/.config/i3
	[ -f ~/.config/i3/config ] && [ ! -L ~/.config/i3/config ] && mv ~/.config/i3/config ~/.config/i3/config.skabak
	ln -sf /opt/skillarch/config/i3/config ~/.config/i3/config

	# polybar config
	[ ! -d ~/.config/polybar ] && mkdir -p ~/.config/polybar
	[ -f ~/.config/polybar/config.ini ] && [ ! -L ~/.config/polybar/config.ini ] && mv ~/.config/polybar/config.ini ~/.config/polybar/config.ini.skabak
	ln -sf /opt/skillarch/config/polybar/config.ini ~/.config/polybar/config.ini
	[ -f ~/.config/polybar/launch.sh ] && [ ! -L ~/.config/polybar/launch.sh ] && mv ~/.config/polybar/launch.sh ~/.config/polybar/launch.sh.skabak
	ln -sf /opt/skillarch/config/polybar/launch.sh ~/.config/polybar/launch.sh

	# picom config
	[ -f ~/.config/picom.conf ] && [ ! -L ~/.config/picom.conf ] && mv ~/.config/picom.conf ~/.config/picom.conf.skabak
	ln -sf /opt/skillarch/config/picom.conf ~/.config/picom.conf

	# touchpad config (X11)
	[ ! -d /etc/X11/xorg.conf.d ] && sudo mkdir -p /etc/X11/xorg.conf.d
	[ -f /etc/X11/xorg.conf.d/30-touchpad.conf ] && sudo mv /etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf.skabak
	sudo ln -sf /opt/skillarch/config/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf

	@echo "✅ i3-gaps (X11) installed!"
	@echo "   WM: i3-gaps | Bar: Polybar | Compositor: Picom"
	@echo "   Screenshots: Flameshot | Lock: i3lock-fancy"
	make clean

.PHONY: install-gui-hyprland
install-gui-hyprland: sanity-check ## Install Hyprland compositor (Wayland)
	[ ! -f /etc/machine-id ] && sudo systemd-machine-id-setup

	# Hyprland compositor packages
	yes|sudo pacman -S --noconfirm --needed \
		hyprland hyprlock hypridle hyprpaper hyprpicker hyprsunset hyprcursor \
		xdg-desktop-portal-hyprland

	# Wayland status bar
	yes|sudo pacman -S --noconfirm --needed waybar

	# Wayland utilities
	yes|sudo pacman -S --noconfirm --needed \
		dunst grim slurp wl-clipboard clipse wlr-randr

	# Wayland support for Qt apps
	yes|sudo pacman -S --noconfirm --needed qt5-wayland qt6-wayland hyprland-qt-support

	# Audio (PipeWire + WirePlumber)
	yes|sudo pacman -S --noconfirm --needed pipewire wireplumber pipewire-pulse pipewire-alsa

	# AUR packages
	yay --noconfirm --needed -S hyprpolkitagent wlogout

	# Create Hyprland config directories
	mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/dunst ~/.config/clipse ~/.config/xdg-desktop-portal

	# Determine which Hyprland config to use (Desktop vs VM)
	@if [ "$(HYPR_MODE)" = "vm" ]; then \
		echo "   Using Hyprland VM config (optimized, no animations/blur)"; \
		[ -f ~/.config/hypr/hyprland.conf ] && [ ! -L ~/.config/hypr/hyprland.conf ] && mv ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.skabak; \
		ln -sf /opt/skillarch/config/hypr/hyprland-vm.conf ~/.config/hypr/hyprland.conf; \
	else \
		echo "   Using Hyprland Desktop config (animations, blur, eye candy)"; \
		[ -f ~/.config/hypr/hyprland.conf ] && [ ! -L ~/.config/hypr/hyprland.conf ] && mv ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.skabak; \
		ln -sf /opt/skillarch/config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf; \
	fi

	# Create empty monitors.conf if it doesn't exist (sourced by hyprland.conf for custom multi-monitor setups)
	touch ~/.config/hypr/monitors.conf

	# hyprpaper config
	[ -f ~/.config/hypr/hyprpaper.conf ] && [ ! -L ~/.config/hypr/hyprpaper.conf ] && mv ~/.config/hypr/hyprpaper.conf ~/.config/hypr/hyprpaper.conf.skabak
	ln -sf /opt/skillarch/config/hypr/hyprpaper.conf ~/.config/hypr/hyprpaper.conf

	# hyprsunset config
	[ -f ~/.config/hypr/hyprsunset.conf ] && [ ! -L ~/.config/hypr/hyprsunset.conf ] && mv ~/.config/hypr/hyprsunset.conf ~/.config/hypr/hyprsunset.conf.skabak
	ln -sf /opt/skillarch/config/hypr/hyprsunset.conf ~/.config/hypr/hyprsunset.conf

	# hyprlock config
	[ -f ~/.config/hypr/hyprlock.conf ] && [ ! -L ~/.config/hypr/hyprlock.conf ] && mv ~/.config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf.skabak
	ln -sf /opt/skillarch/config/hypr/hyprlock.conf ~/.config/hypr/hyprlock.conf

	# hypridle config
	[ -f ~/.config/hypr/hypridle.conf ] && [ ! -L ~/.config/hypr/hypridle.conf ] && mv ~/.config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf.skabak
	ln -sf /opt/skillarch/config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf

	# waybar config
	[ -f ~/.config/waybar/config.jsonc ] && [ ! -L ~/.config/waybar/config.jsonc ] && mv ~/.config/waybar/config.jsonc ~/.config/waybar/config.jsonc.skabak
	ln -sf /opt/skillarch/config/hypr/waybar/config.jsonc ~/.config/waybar/config.jsonc
	[ -f ~/.config/waybar/style.css ] && [ ! -L ~/.config/waybar/style.css ] && mv ~/.config/waybar/style.css ~/.config/waybar/style.css.skabak
	ln -sf /opt/skillarch/config/hypr/waybar/style.css ~/.config/waybar/style.css

	# waybar scripts
	[ -d ~/.config/waybar/scripts ] && [ ! -L ~/.config/waybar/scripts ] && mv ~/.config/waybar/scripts ~/.config/waybar/scripts.skabak
	ln -sfn /opt/skillarch/config/hypr/waybar/scripts ~/.config/waybar/scripts

	# dunst config
	[ -f ~/.config/dunst/dunstrc ] && [ ! -L ~/.config/dunst/dunstrc ] && mv ~/.config/dunst/dunstrc ~/.config/dunst/dunstrc.skabak
	ln -sf /opt/skillarch/config/hypr/dunst/dunstrc ~/.config/dunst/dunstrc

	# clipse configs
	[ -f ~/.config/clipse/config.json ] && [ ! -L ~/.config/clipse/config.json ] && mv ~/.config/clipse/config.json ~/.config/clipse/config.json.skabak
	ln -sf /opt/skillarch/config/hypr/clipse/config.json ~/.config/clipse/config.json
	[ -f ~/.config/clipse/custom_theme.json ] && [ ! -L ~/.config/clipse/custom_theme.json ] && mv ~/.config/clipse/custom_theme.json ~/.config/clipse/custom_theme.json.skabak
	ln -sf /opt/skillarch/config/hypr/clipse/custom_theme.json ~/.config/clipse/custom_theme.json

	# xdg-desktop-portal configs
	[ -f ~/.config/xdg-desktop-portal/hyprland.portals ] && [ ! -L ~/.config/xdg-desktop-portal/hyprland.portals ] && mv ~/.config/xdg-desktop-portal/hyprland.portals ~/.config/xdg-desktop-portal/hyprland.portals.skabak
	ln -sf /opt/skillarch/config/hypr/xdg-desktop-portal/hyprland.portals ~/.config/xdg-desktop-portal/hyprland.portals
	[ -f ~/.config/xdg-desktop-portal/portals.conf ] && [ ! -L ~/.config/xdg-desktop-portal/portals.conf ] && mv ~/.config/xdg-desktop-portal/portals.conf ~/.config/xdg-desktop-portal/portals.conf.skabak
	ln -sf /opt/skillarch/config/hypr/xdg-desktop-portal/portals.conf ~/.config/xdg-desktop-portal/portals.conf

	# start-bar.sh script
	mkdir -p ~/.config/hypr/scripts
	[ -f ~/.config/hypr/scripts/start-bar.sh ] && [ ! -L ~/.config/hypr/scripts/start-bar.sh ] && mv ~/.config/hypr/scripts/start-bar.sh ~/.config/hypr/scripts/start-bar.sh.skabak || true
	ln -sf /opt/skillarch/config/hypr/scripts/start-bar.sh ~/.config/hypr/scripts/start-bar.sh
	chmod +x /opt/skillarch/config/hypr/scripts/start-bar.sh

	@echo "✅ Hyprland (Wayland) installed!"
	@echo "   Compositor: Hyprland | Bar: Waybar"
	@echo "   Screenshots: Grim+Slurp | Lock: Hyprlock | Idle: Hypridle"
	@if [ "$(HYPR_MODE)" = "vm" ]; then \
		echo "   Mode: VM (optimized for VirtualBox/VMware)"; \
	else \
		echo "   Mode: Desktop (animations, blur, effects)"; \
	fi
	make clean

.PHONY: install-eww
install-eww: sanity-check ## Install eww bar + Activate Linux watermark (Hyprland only)
	@echo "════════════════════════════════════════════════════════"
	@echo "  Installing eww bar (Everforest)"
	@echo "════════════════════════════════════════════════════════"
	yay --noconfirm --needed -S eww

	# Create config directories
	mkdir -p ~/.config/eww ~/.config/hypr/scripts ~/.config/skillarch

	# Backup existing configs if they exist and are not symlinks
	[ -f ~/.config/eww/eww.yuck ] && [ ! -L ~/.config/eww/eww.yuck ] && mv ~/.config/eww/eww.yuck ~/.config/eww/eww.yuck.skabak || true
	[ -f ~/.config/eww/eww.scss ] && [ ! -L ~/.config/eww/eww.scss ] && mv ~/.config/eww/eww.scss ~/.config/eww/eww.scss.skabak || true
	[ -d ~/.config/eww/scripts ] && [ ! -L ~/.config/eww/scripts ] && mv ~/.config/eww/scripts ~/.config/eww/scripts.skabak || true

	# Create symlinks for eww config
	ln -sf /opt/skillarch/config/hypr/eww/eww.yuck ~/.config/eww/eww.yuck
	ln -sf /opt/skillarch/config/hypr/eww/eww.scss ~/.config/eww/eww.scss
	ln -sfn /opt/skillarch/config/hypr/eww/scripts ~/.config/eww/scripts
	chmod +x /opt/skillarch/config/hypr/eww/scripts/*.sh

	# Symlink start-bar.sh
	[ -f ~/.config/hypr/scripts/start-bar.sh ] && [ ! -L ~/.config/hypr/scripts/start-bar.sh ] && mv ~/.config/hypr/scripts/start-bar.sh ~/.config/hypr/scripts/start-bar.sh.skabak || true
	ln -sf /opt/skillarch/config/hypr/scripts/start-bar.sh ~/.config/hypr/scripts/start-bar.sh
	chmod +x /opt/skillarch/config/hypr/scripts/start-bar.sh

	# Set eww as default bar choice
	echo "eww" > ~/.config/skillarch/bar-choice

	@echo ""
	@echo "✅ eww bar installed!"
	@echo "   Bar: eww (Everforest) | Watermark: Activate Linux"
	@echo "   Toggle: ska-bar-toggle (switch between eww and Waybar)"
	@echo "   Manual: eww daemon && eww open bar"
	@echo "   Stop:   eww close-all && eww kill"

.PHONY: install-gui
install-gui: sanity-check validate-wm-choice install-gui-common ## Install GUI environment (conditional based on WM choice)
	@echo "════════════════════════════════════════════════════════"
	@echo "  Installing GUI based on your choice: $(WM_CHOICE)"
	@echo "════════════════════════════════════════════════════════"
	@if [ "$(WM_CHOICE)" = "i3" ]; then \
		$(MAKE) install-gui-i3; \
	elif [ "$(WM_CHOICE)" = "hyprland" ]; then \
		$(MAKE) install-gui-hyprland; \
	fi
	@echo ""
	@echo "✅ GUI installation complete!"

install-gui-tools: sanity-check ## Install system packages
	yes|sudo pacman -S --noconfirm --needed vlc-luajit # Must be done before obs-studio-browser to avoid conflicts
	yes|sudo pacman -S --noconfirm --needed arandr cheese code code-marketplace discord dunst filezilla flameshot ghex google-chrome gparted kompare libreoffice-fresh meld obsidian okular qbittorrent torbrowser-launcher wireshark-qt ghidra signal-desktop dragon-drop-git nomachine obs-studio-browser emote guvcview audacity polkit-gnome
	yay --noconfirm --needed -S zen-browser-bin
	# Do not start services in docker
	[ ! -f /.dockerenv ] && sudo systemctl disable --now nxserver.service
	xargs -n1 -I{} code --install-extension {} --force < config/extensions.txt
	yay --noconfirm --needed -S fswebcam cursor-bin
	sudo ln -sf /usr/bin/google-chrome-stable /usr/local/bin/gog
	make clean

install-offensive: sanity-check ## Install offensive tools
	yes|sudo pacman -S --noconfirm --needed metasploit fx lazygit fq gitleaks jdk21-openjdk burpsuite hashcat bettercap
	sudo sed -i 's#$JAVA_HOME#/usr/lib/jvm/java-21-openjdk#g' /usr/bin/burpsuite
	yay --noconfirm --needed -S ffuf gau pdtm-bin waybackurls fabric-ai-bin

	# Hide stdout and Keep stderr for CI builds
	mise exec -- go install github.com/sw33tLie/sns@latest > /dev/null
	mise exec -- go install github.com/glitchedgitz/cook/v2/cmd/cook@latest > /dev/null
	mise exec -- go install github.com/x90skysn3k/brutespray@latest > /dev/null
	mise exec -- go install github.com/sensepost/gowitness@latest > /dev/null
	mise exec -- go version >/dev/null 2>&1 || { echo "ERROR: go not available via mise"; exit 1; }
	zsh -c "source ~/.zshrc && pdtm -install-all -v"
	zsh -c "source ~/.zshrc && nuclei -update-templates -update-template-dir ~/.nuclei-templates"

	# Clone custom tools
	pushd /tmp # Avoid git clone --depth=1 in root
	[ ! -d /opt/chisel ] && git clone --depth=1 https://github.com/jpillora/chisel && sudo mv chisel /opt/chisel
	[ ! -d /opt/phpggc ] && git clone --depth=1 https://github.com/ambionics/phpggc && sudo mv phpggc /opt/phpggc
	[ ! -d /opt/PyFuscation ] && git clone --depth=1 https://github.com/CBHue/PyFuscation && sudo mv PyFuscation /opt/PyFuscation
	[ ! -d /opt/CloudFlair ] && git clone --depth=1 https://github.com/christophetd/CloudFlair && sudo mv CloudFlair /opt/CloudFlair
	[ ! -d /opt/minos-static ] && git clone --depth=1 https://github.com/minos-org/minos-static && sudo mv minos-static /opt/minos-static
	[ ! -d /opt/exploit-database ] && git clone --depth=1 https://github.com/offensive-security/exploit-database && sudo mv exploit-database /opt/exploit-database
	[ ! -d /opt/exploitdb ] && git clone --depth=1 https://gitlab.com/exploit-database/exploitdb && sudo mv exploitdb /opt/exploitdb
	[ ! -d /opt/pty4all ] && git clone --depth=1 https://github.com/laluka/pty4all && sudo mv pty4all /opt/pty4all
	[ ! -d /opt/pypotomux ] && git clone --depth=1 https://github.com/laluka/pypotomux && sudo mv pypotomux /opt/pypotomux
	popd
	make clean

install-wordlists: sanity-check ## Install wordlists
	[ ! -d /opt/lists ] && mkdir /tmp/lists && sudo mv /tmp/lists /opt/lists
	[ ! -f /opt/lists/rockyou.txt ] && curl -L https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -o /opt/lists/rockyou.txt
	[ ! -d /opt/lists/PayloadsAllTheThings ] && git clone --depth=1 https://github.com/swisskyrepo/PayloadsAllTheThings /opt/lists/PayloadsAllTheThings
	[ ! -d /opt/lists/BruteX ] && git clone --depth=1 https://github.com/1N3/BruteX /opt/lists/BruteX
	[ ! -d /opt/lists/IntruderPayloads ] && git clone --depth=1 https://github.com/1N3/IntruderPayloads /opt/lists/IntruderPayloads
	[ ! -d /opt/lists/Probable-Wordlists ] && git clone --depth=1 https://github.com/berzerk0/Probable-Wordlists /opt/lists/Probable-Wordlists
	[ ! -d /opt/lists/Open-Redirect-Payloads ] && git clone --depth=1 https://github.com/cujanovic/Open-Redirect-Payloads /opt/lists/Open-Redirect-Payloads
	[ ! -d /opt/lists/SecLists ] && git clone --depth=1 https://github.com/danielmiessler/SecLists /opt/lists/SecLists
	[ ! -d /opt/lists/Pwdb-Public ] && git clone --depth=1 https://github.com/ignis-sec/Pwdb-Public /opt/lists/Pwdb-Public
	[ ! -d /opt/lists/Bug-Bounty-Wordlists ] && git clone --depth=1 https://github.com/Karanxa/Bug-Bounty-Wordlists /opt/lists/Bug-Bounty-Wordlists
	[ ! -d /opt/lists/richelieu ] && git clone --depth=1 https://github.com/tarraschk/richelieu /opt/lists/richelieu
	[ ! -d /opt/lists/webapp-wordlists ] && git clone --depth=1 https://github.com/p0dalirius/webapp-wordlists /opt/lists/webapp-wordlists
	make clean

install-hardening: sanity-check ## Install hardening tools
	yes|sudo pacman -S --noconfirm --needed opensnitch
	# OPT-IN opensnitch as an egress firewall
	# sudo systemctl enable --now opensnitchd.service
	make clean

update: sanity-check ## Update SkillArch
	@[ -n "$$(git status --porcelain)" ] && echo "Error: git state is dirty, please "git stash" your changes before updating" && exit 1
	@[ "$$(git rev-parse --abbrev-ref HEAD)" != "main" ] && echo "Error: current branch is not main, please switch to main before updating" && exit 1
	@git pull
	@echo "SkillArch updated, please run make install to apply changes 🙏"

docker-build:  ## Build lite docker image locally
	docker build -t thelaluka/skillarch:lite -f Dockerfile-lite .

docker-build-full: docker-build  ## Build full docker image locally
	docker build -t thelaluka/skillarch:full -f Dockerfile-full .

docker-build-full-i3: docker-build  ## Build full i3 docker image locally
	docker build -t thelaluka/skillarch:full-i3 -f Dockerfile-full-i3 .

docker-build-full-hyprland: docker-build  ## Build full Hyprland docker image locally
	docker build -t thelaluka/skillarch:full-hyprland -f Dockerfile-full-hyprland .

docker-run:  ## Run lite docker image locally
	sudo docker run --rm -it --name=ska --net=host -v /tmp:/tmp thelaluka/skillarch:lite

docker-run-full:  ## Run full docker image locally
	xhost +
	sudo docker run --rm -it --name=ska --net=host -v /tmp:/tmp -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ --privileged thelaluka/skillarch:full

docker-run-full-i3:  ## Run full i3 docker image locally
	xhost +
	sudo docker run --rm -it --name=ska-i3 --net=host -v /tmp:/tmp -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ --privileged thelaluka/skillarch:full-i3

docker-run-full-hyprland:  ## Run full Hyprland docker image locally
	xhost +
	sudo docker run --rm -it --name=ska-hyprland --net=host -v /tmp:/tmp -e DISPLAY -e XDG_RUNTIME_DIR -e WAYLAND_DISPLAY -v /run/user/$$(id -u):/run/user/$$(id -u) --privileged thelaluka/skillarch:full-hyprland

clean: ## Clean up system and remove unnecessary files
	[ ! -f /.dockerenv ] && exit
	yes|sudo pacman -Scc
	yes|sudo pacman -Sc
	yes|sudo pacman -Rns $$(pacman -Qtdq) 2>/dev/null || true
	rm -rf ~/.cache/pip
	npm cache clean --force 2>/dev/null || true
	mise cache clear
	go clean -cache -modcache -i -r 2>/dev/null || true
	sudo rm -rf /var/cache/*
	rm -rf ~/.cache/*
	sudo rm -rf /tmp/*
	docker system prune -af 2>/dev/null || true
	sudo journalctl --vacuum-time=1d
	sudo find /var/log -type f -name "*.old" -delete
	sudo find /var/log -type f -name "*.gz" -delete
	sudo find /var/log -type f -exec truncate --size=0 {} \;
