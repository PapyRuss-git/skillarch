# base.mk - install-base, install-cli-tools

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
	yes|sudo pacman -S --noconfirm --needed base-devel bison bzip2 ca-certificates cloc cmake dos2unix expect ffmpeg foremost gdb gnupg htop bottom hwinfo icu inotify-tools iproute2 jq llvm lsof ltrace make mlocate mplayer ncurses net-tools ngrep nmap openssh openssl parallel perl-image-exiftool pkgconf python-virtualenv re2c readline ripgrep rlwrap socat gnu-netcat sqlite sshpass tmate tor traceroute trash-cli tree unzip vbindiff xclip xz yay zip veracrypt git-delta github-cli viu xsv asciinema htmlq neovim glow jless websocat superfile gron eza fastfetch bat sysstat cronie starship
	sudo ln -sf /usr/bin/bat /usr/local/bin/batcat
	bash -c "$$(curl -fsSL https://gef.blah.cat/sh)"
	# eza doesn't need the libgit2 workaround that exa required
	# nvim config
	[ ! -d ~/.config/nvim ] && git clone --depth=1 https://github.com/LazyVim/starter ~/.config/nvim
	$(call symlink,$(SKA_CONFIG)/nvim/init.lua,~/.config/nvim/init.lua)
	rm -rf ~/.config/nvim/lua ~/.config/nvim/ftplugin
	ln -sfn $(SKA_CONFIG)/nvim/lua ~/.config/nvim/lua
	ln -sfn $(SKA_CONFIG)/nvim/ftplugin ~/.config/nvim/ftplugin
	ln -sfn $(SKA_CONFIG)/nvim/lazy-lock.json ~/.config/nvim/lazy-lock.json
	nvim --headless +"Lazy! sync" +qa >/dev/null # Download and update plugins

	# Install pipx & tools
	yay --noconfirm --needed -S python-pipx
	pipx ensurepath
	while IFS= read -r package; do \
		[ -z "$$package" ] || [ "$${package#\#}" != "$$package" ] && continue; \
		pipx install -q "$$package" && pipx inject -q "$$package" setuptools || echo "WARNING: pipx $$package failed"; \
	done < $(SKA_CONFIG)/lists/pipx-packages.txt

	# Install mise and all php-build dependencies
	yes|sudo pacman -S --noconfirm --needed mise libedit libffi libjpeg-turbo libpcap libpng libxml2 libzip postgresql-libs php-gd
	# mise self-update # Currently broken, wait for upstream fix, pinged on 17/03/2025
	for i in $$(seq 1 30); do command -v mise >/dev/null 2>&1 && break || sleep 1; done
	command -v mise >/dev/null 2>&1 || { echo "ERROR: mise not found after install"; exit 1; }
	while IFS= read -r package; do \
		[ -z "$$package" ] || [ "$${package#\#}" != "$$package" ] && continue; \
		mise use -g "$$package@latest" && mise exec -- true || { echo "ERROR: mise use $$package failed"; exit 1; }; \
	done < $(SKA_CONFIG)/lists/mise-packages.txt
	mise exec -- go env -w "GOPATH=/home/$$USER/.local/go"
	make clean
