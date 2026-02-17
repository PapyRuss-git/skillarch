# shell.mk - install-shell

install-shell: sanity-check ## Install shell packages
	# Install and Configure zsh and oh-my-zsh
	yes|sudo pacman -S --noconfirm --needed zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions zsh-history-substring-search zsh-theme-powerlevel10k
	[ ! -d ~/.oh-my-zsh ] && sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	$(call symlink,/opt/skillarch/config/zshrc,~/.zshrc)
	[ ! -d ~/.oh-my-zsh/plugins/zsh-completions ] && git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/plugins/zsh-completions
	[ ! -d ~/.oh-my-zsh/plugins/zsh-autosuggestions ] && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions
	[ ! -d ~/.oh-my-zsh/plugins/zsh-syntax-highlighting ] && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting
	[ ! -d ~/.ssh ] && mkdir ~/.ssh && chmod 700 ~/.ssh # Must exist for ssh-agent to work
	for plugin in colored-man-pages docker extract fzf mise npm terraform tmux zsh-autosuggestions zsh-completions zsh-syntax-highlighting ssh-agent; do zsh -c "source ~/.zshrc && omz plugin enable $$plugin || true"; done
	make clean

	# Install and configure fzf, tmux, vim
	[ ! -d ~/.fzf ] && git clone --depth=1 https://github.com/junegunn/fzf ~/.fzf && ~/.fzf/install --all
	$(call symlink,/opt/skillarch/config/tmux.conf,~/.tmux.conf)
	$(call symlink,/opt/skillarch/config/vimrc,~/.vimrc)
	# Set the default user shell to zsh
	sudo chsh -s /usr/bin/zsh "$$USER" # Logout required to be applied
