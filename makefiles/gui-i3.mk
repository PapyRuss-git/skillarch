# gui-i3.mk - install-gui-i3

.PHONY: install-gui-i3
install-gui-i3: sanity-check ## Install i3 window manager (X11)
	[ ! -f /etc/machine-id ] && sudo systemd-machine-id-setup

	# i3 window manager packages
	yes|sudo pacman -S --noconfirm --needed \
		i3-gaps i3lock i3lock-fancy-git \
		polybar picom dmenu

	# X11 utilities
	yes|sudo pacman -S --noconfirm --needed \
		feh flameshot xss-lock \
		xorg-server xorg-xinit xorg-xrandr xorg-xhost \
		xclip xdotool

	# X11 portal & polkit
	yes|sudo pacman -S --noconfirm --needed xdg-desktop-portal-gtk polkit-gnome

	# VM guest integration (clipboard + dynamic resolution in QEMU/KVM/GNOME Boxes & VMware)
	# VirtualBox guest utils stay opt-in via the ska-vbox-install-guestutils alias.
	yes|sudo pacman -S --noconfirm --needed spice-vdagent open-vm-tools

	# AUR packages
	yay --noconfirm --needed -S rofi-power-menu i3-battery-popup-git

	# i3 config
	[ ! -d ~/.config/i3 ] && mkdir -p ~/.config/i3
	$(call symlink,$(SKA_CONFIG)/i3/config,~/.config/i3/config)

	# VM guest integration helper (started from ~/.config/i3/config)
	$(call symlink,$(SKA_CONFIG)/i3/vm-guest-integration.sh,~/.config/i3/vm-guest-integration.sh)
	chmod +x $(SKA_CONFIG)/i3/vm-guest-integration.sh

	# polybar config
	[ ! -d ~/.config/polybar ] && mkdir -p ~/.config/polybar
	$(call symlink,$(SKA_CONFIG)/polybar/config.ini,~/.config/polybar/config.ini)
	$(call symlink,$(SKA_CONFIG)/polybar/launch.sh,~/.config/polybar/launch.sh)

	# picom config
	$(call symlink,$(SKA_CONFIG)/picom.conf,~/.config/picom.conf)

	# touchpad config (X11)
	[ ! -d /etc/X11/xorg.conf.d ] && sudo mkdir -p /etc/X11/xorg.conf.d
	[ -f /etc/X11/xorg.conf.d/30-touchpad.conf ] && sudo mv /etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf.skabak
	sudo ln -sf $(SKA_CONFIG)/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf

	@echo "✅ i3-gaps (X11) installed!"
	@echo "   WM: i3-gaps | Bar: Polybar | Compositor: Picom"
	@echo "   Screenshots: Flameshot | Lock: i3lock-fancy"
	@echo "   VM-ready: picom auto-disabled in hypervisors + guest integration (VBox/SPICE/VMware)"
	make clean
