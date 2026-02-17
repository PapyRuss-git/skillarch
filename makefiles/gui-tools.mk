# gui-tools.mk - install-gui-tools

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
