# gui-common.mk - install-gui-common, install-gui (dispatcher)

.PHONY: install-gui-common
install-gui-common: sanity-check ## Install common GUI packages (X11 + Wayland compatible)
	# Common terminal & fonts
	yes|sudo pacman -S --noconfirm --needed \
		kitty ghostty \
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

	# Everforest GTK theme + icons (murrine must be installed first, it's a dependency of everforest-icon)
	yay --noconfirm --needed -S gtk-engine-murrine
	yay --noconfirm --needed -S colloid-everforest-gtk-theme-git everforest-icon-theme-git

	# Dark mode + Everforest GTK theme
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	gsettings set org.gnome.desktop.interface gtk-theme 'Colloid-Dark-Everforest'
	gsettings set org.gnome.desktop.interface icon-theme 'Everforest-Dark'

	# Everforest icons: switch folder color to mint
	# Large sizes (32+): repoint symlinks from oomox to mint
	find /usr/share/icons/Everforest-Dark/places/ -name "folder*.svg" -type l | while read link; do \
		target=$$(readlink "$$link"); \
		new_target=$$(echo "$$target" | sed 's/folder-oomox/folder-mint/'); \
		dir=$$(dirname "$$link"); \
		[ -f "$$dir/$$new_target" ] && ln -sf "$$new_target" "$$link"; \
	done
	# Small sizes (16,22,24): no mint-specific variants, replace generic files with mint base
	for size in 16 16@2x 22 22@2x 24 24@2x; do \
		dir="/usr/share/icons/Everforest-Dark/places/$$size"; \
		[ -f "$$dir/folder-mint.svg" ] || continue; \
		for f in $$dir/folder.svg $$dir/folder-*.svg; do \
			[ -f "$$f" ] && [ ! -L "$$f" ] && [ "$$f" != "$$dir/folder-mint.svg" ] && cp "$$dir/folder-mint.svg" "$$f"; \
		done; \
	done
	# Fix broken symbolic icons (missing viewBox, invisible in GTK4/libadwaita sidebar)
	# Replace with Adwaita equivalents where available
	for name in folder-documents-symbolic.svg folder-download-symbolic.svg folder-pictures-symbolic.svg \
		folder-publicshare-symbolic.svg folder-remote-symbolic.svg folder-templates-symbolic.svg \
		user-desktop-symbolic.svg user-home-symbolic.svg user-trash-symbolic.svg; do \
		[ -f /usr/share/icons/Adwaita/symbolic/places/$$name ] && \
		cp /usr/share/icons/Adwaita/symbolic/places/$$name /usr/share/icons/Everforest-Dark/places/symbolic/$$name; \
	done
	# For broken icons without Adwaita equivalent, use the working folder-symbolic
	for name in folder-activities-symbolic.svg folder-apps-symbolic.svg folder-mac-symbolic.svg \
		folder-open-symbolic.svg folder-recent-symbolic.svg folder-search-symbolic.svg \
		folder-video-symbolic.svg user-trash-full-symbolic.svg; do \
		cp /usr/share/icons/Everforest-Dark/places/symbolic/folder-symbolic.svg \
		   /usr/share/icons/Everforest-Dark/places/symbolic/$$name; \
	done
	# Nautilus "Favoris" sidebar: replace broken starred icon + add favorites alias
	cp /usr/share/icons/Adwaita/symbolic/status/starred-symbolic.svg \
	   /usr/share/icons/Everforest-Dark/status/symbolic/starred-symbolic.svg
	for dir in status/symbolic places/symbolic actions/symbolic; do \
		cp /usr/share/icons/Adwaita/symbolic/status/starred-symbolic.svg \
		   /usr/share/icons/Everforest-Dark/$$dir/favorites-symbolic.svg; \
	done
	gtk-update-icon-cache -f -t /usr/share/icons/Everforest-Dark/
	gtk4-update-icon-cache -f -t /usr/share/icons/Everforest-Dark/ || true

	# GTK4/libadwaita theme (Nautilus, GNOME apps)
	[ ! -d ~/.config/gtk-4.0 ] && mkdir -p ~/.config/gtk-4.0
	ln -sf /usr/share/themes/Colloid-Dark-Everforest/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
	ln -sf /usr/share/themes/Colloid-Dark-Everforest/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
	ln -sf /usr/share/themes/Colloid-Dark-Everforest/gtk-4.0/assets ~/.config/gtk-4.0/assets

	# kitty config (common)
	[ ! -d ~/.config/kitty ] && mkdir -p ~/.config/kitty
	$(call symlink,$(SKA_CONFIG)/kitty/kitty.conf,~/.config/kitty/kitty.conf)

	# ghostty config (common)
	[ ! -d ~/.config/ghostty ] && mkdir -p ~/.config/ghostty
	$(call symlink,$(SKA_CONFIG)/ghostty/config,~/.config/ghostty/config)

	# rofi config (common)
	[ ! -d ~/.config/rofi ] && mkdir -p ~/.config/rofi
	$(call symlink,$(SKA_CONFIG)/rofi/config.rasi,~/.config/rofi/config.rasi)
	make clean

.PHONY: install-gui
install-gui: sanity-check validate-wm-choice install-gui-common ## Install GUI environment (conditional based on WM choice)
	@echo "════════════════════════════════════════════════════════"
	@echo "  Installing GUI based on your choice: $(WM_CHOICE)"
	@echo "════════════════════════════════════════════════════════"
	@if [ "$(WM_CHOICE)" = "i3" ]; then \
		$(MAKE) install-gui-i3; \
	elif [ "$(WM_CHOICE)" = "hyprland" ]; then \
		$(MAKE) install-gui-hyprland; \
		$(MAKE) install-quickshell; \
	fi
	@echo ""
	@echo "✅ GUI installation complete!"
