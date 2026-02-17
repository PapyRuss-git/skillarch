# gui-i3.mk - install-gui-i3

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
	$(call symlink,/opt/skillarch/config/i3/config,~/.config/i3/config)

	# polybar config
	[ ! -d ~/.config/polybar ] && mkdir -p ~/.config/polybar
	$(call symlink,/opt/skillarch/config/polybar/config.ini,~/.config/polybar/config.ini)
	$(call symlink,/opt/skillarch/config/polybar/launch.sh,~/.config/polybar/launch.sh)

	# picom config
	$(call symlink,/opt/skillarch/config/picom.conf,~/.config/picom.conf)

	# touchpad config (X11)
	[ ! -d /etc/X11/xorg.conf.d ] && sudo mkdir -p /etc/X11/xorg.conf.d
	[ -f /etc/X11/xorg.conf.d/30-touchpad.conf ] && sudo mv /etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf.skabak
	sudo ln -sf /opt/skillarch/config/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf

	@echo "✅ i3-gaps (X11) installed!"
	@echo "   WM: i3-gaps | Bar: Polybar | Compositor: Picom"
	@echo "   Screenshots: Flameshot | Lock: i3lock-fancy"
	make clean
