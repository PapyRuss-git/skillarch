# gui-hyprland.mk - install-gui-hyprland, install-quickshell

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
		swaync grim slurp wl-clipboard clipse wlr-randr

	# Wayland support for Qt apps
	yes|sudo pacman -S --noconfirm --needed qt5-wayland qt6-wayland qt6ct hyprland-qt-support

	# Audio (PipeWire + WirePlumber)
	yes|sudo pacman -S --noconfirm --needed pipewire wireplumber pipewire-pulse pipewire-alsa

	# AUR packages
	yay --noconfirm --needed -S hyprpolkitagent wlogout

	# Create Hyprland config directories
	mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/swaync ~/.config/clipse ~/.config/xdg-desktop-portal ~/.config/qt6ct/colors

	# Hyprland config (single source, mode-specific overrides via hyprland-mode.lua)
	# Hyprland >= 0.55 uses the Lua config format; the hyprlang .conf format is deprecated
	$(call symlink,$(SKA_CONFIG)/hypr/hyprland.lua,~/.config/hypr/hyprland.lua)
	$(call symlink,$(SKA_CONFIG)/hypr/application-style.conf,~/.config/hypr/application-style.conf)
	@if [ "$(HYPR_MODE)" = "vm" ]; then \
		echo "   Mode: VM (optimized, no animations/blur)"; \
		ln -sf $(SKA_CONFIG)/hypr/hyprland-vm.lua ~/.config/hypr/hyprland-mode.lua; \
	else \
		echo "   Mode: Desktop (animations, blur, eye candy)"; \
		ln -sf $(SKA_CONFIG)/hypr/hyprland-desktop.lua ~/.config/hypr/hyprland-mode.lua; \
	fi

	# Remove legacy hyprlang symlinks left by pre-Lua installs
	[ -L ~/.config/hypr/hyprland.conf ] && rm -f ~/.config/hypr/hyprland.conf || true
	[ -L ~/.config/hypr/hyprland-mode.conf ] && rm -f ~/.config/hypr/hyprland-mode.conf || true

	# Create empty monitors.lua if it doesn't exist (sourced by hyprland.lua for custom multi-monitor setups)
	touch ~/.config/hypr/monitors.lua
	@if [ -s ~/.config/hypr/monitors.conf ]; then \
		echo "   ⚠️  ~/.config/hypr/monitors.conf is no longer read — port it to ~/.config/hypr/monitors.lua (hl.monitor / hl.workspace_rule)"; \
	fi

	# hyprpaper config
	$(call symlink,$(SKA_CONFIG)/hypr/hyprpaper.conf,~/.config/hypr/hyprpaper.conf)

	# hyprsunset config
	$(call symlink,$(SKA_CONFIG)/hypr/hyprsunset.conf,~/.config/hypr/hyprsunset.conf)

	# hyprlock config
	$(call symlink,$(SKA_CONFIG)/hypr/hyprlock.conf,~/.config/hypr/hyprlock.conf)

	# hypridle config
	$(call symlink,$(SKA_CONFIG)/hypr/hypridle.conf,~/.config/hypr/hypridle.conf)

	# waybar config
	$(call symlink,$(SKA_CONFIG)/hypr/waybar/config.jsonc,~/.config/waybar/config.jsonc)
	$(call symlink,$(SKA_CONFIG)/hypr/waybar/style.css,~/.config/waybar/style.css)

	# waybar scripts
	$(call symlink-dir,$(SKA_CONFIG)/hypr/waybar/scripts,~/.config/waybar/scripts)

	# swaync config
	$(call symlink,$(SKA_CONFIG)/hypr/swaync/config.json,~/.config/swaync/config.json)
	$(call symlink,$(SKA_CONFIG)/hypr/swaync/style.css,~/.config/swaync/style.css)

	# clipse configs
	$(call symlink,$(SKA_CONFIG)/hypr/clipse/config.json,~/.config/clipse/config.json)
	$(call symlink,$(SKA_CONFIG)/hypr/clipse/custom_theme.json,~/.config/clipse/custom_theme.json)

	# qt6ct config
	$(call symlink,$(SKA_DIR)/config/qt6ct/qt6ct.conf,~/.config/qt6ct/qt6ct.conf)
	$(call symlink,$(SKA_DIR)/config/qt6ct/colors/everforest-hard.conf,~/.config/qt6ct/colors/everforest-hard.conf)

	# xdg-desktop-portal configs
	$(call symlink,$(SKA_CONFIG)/hypr/xdg-desktop-portal/hyprland.portals,~/.config/xdg-desktop-portal/hyprland.portals)
	$(call symlink,$(SKA_CONFIG)/hypr/xdg-desktop-portal/portals.conf,~/.config/xdg-desktop-portal/portals.conf)

	# Hyprland helper scripts
	mkdir -p ~/.config/hypr/scripts
	$(call symlink,$(SKA_CONFIG)/hypr/scripts/start-bar.sh,~/.config/hypr/scripts/start-bar.sh)
	$(call symlink,$(SKA_CONFIG)/hypr/scripts/wallpaper-rotate.sh,~/.config/hypr/scripts/wallpaper-rotate.sh)
	chmod +x $(SKA_CONFIG)/hypr/scripts/start-bar.sh
	chmod +x $(SKA_CONFIG)/hypr/scripts/wallpaper-rotate.sh

	@echo "✅ Hyprland (Wayland) installed!"
	@echo "   Compositor: Hyprland | Bar: Quickshell (default)"
	@echo "   Notifications: Swaync"
	@echo "   Alternative bar: Waybar (toggle via 'ska-bar-toggle')"
	@echo "   Screenshots: Grim+Slurp | Lock: Hyprlock | Idle: Hypridle"
	@if [ "$(HYPR_MODE)" = "vm" ]; then \
		echo "   Mode: VM (optimized for VirtualBox/VMware)"; \
	else \
		echo "   Mode: Desktop (animations, blur, effects)"; \
	fi
	make clean

.PHONY: install-quickshell
install-quickshell: sanity-check ## Install Quickshell bar (Hyprland only)
	@echo "════════════════════════════════════════════════════════"
	@echo "  Installing Quickshell bar (Everforest)"
	@echo "════════════════════════════════════════════════════════"
	yes|sudo pacman -S --noconfirm --needed quickshell

	# Create config directories
	mkdir -p ~/.config/quickshell ~/.config/hypr/scripts ~/.config/skillarch

	# Backup existing configs if they exist and are not symlinks
	[ -d ~/.config/quickshell ] && [ ! -L ~/.config/quickshell ] && [ "$$(ls -A ~/.config/quickshell 2>/dev/null)" ] && mv ~/.config/quickshell ~/.config/quickshell.skabak || true

	# Symlink entire quickshell config directory
	rm -rf ~/.config/quickshell
	ln -sfn $(SKA_CONFIG)/hypr/quickshell ~/.config/quickshell
	chmod +x $(SKA_CONFIG)/hypr/quickshell/scripts/*.sh

	# Symlink Hyprland helper scripts
	$(call symlink,$(SKA_CONFIG)/hypr/scripts/start-bar.sh,~/.config/hypr/scripts/start-bar.sh)
	$(call symlink,$(SKA_CONFIG)/hypr/scripts/wallpaper-rotate.sh,~/.config/hypr/scripts/wallpaper-rotate.sh)
	chmod +x $(SKA_CONFIG)/hypr/scripts/start-bar.sh
	chmod +x $(SKA_CONFIG)/hypr/scripts/wallpaper-rotate.sh

	# Set quickshell as default bar choice
	echo "quickshell" > ~/.config/skillarch/bar-choice

	@echo ""
	@echo "✅ Quickshell bar installed!"
	@echo "   Bar: Quickshell (Everforest) | Watermark: Activate Linux"
	@echo "   Persists choice in ~/.config/skillarch/bar-choice"
	@echo "   Toggle: ska-bar-toggle (cycle waybar <-> quickshell)"
	@echo "   Manual: quickshell"
	@echo "   Stop:   killall quickshell"
