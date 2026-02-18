# test.mk - post-install validation

.PHONY: test test-commands test-symlinks test-wm

test: test-commands test-symlinks test-wm ## Run post-install validation tests
	@echo ""
	@echo "✅ All tests passed!"

test-commands: ## Validate essential commands are available
	@echo "── Testing commands ──"
	@fail=0; \
	for cmd in zsh nvim tmux vim git curl wget jq rg fzf bat eza kitty rofi; do \
		if command -v $$cmd >/dev/null 2>&1; then \
			echo "  ✅ $$cmd"; \
		else \
			echo "  ❌ $$cmd not found"; \
			fail=1; \
		fi; \
	done; \
	[ $$fail -eq 0 ] || { echo "FAIL: some commands are missing"; exit 1; }

test-symlinks: ## Validate config symlinks point to SKA_DIR
	@echo "── Testing symlinks ──"
	@fail=0; \
	for link in \
		~/.zshrc \
		~/.tmux.conf \
		~/.vimrc \
		~/.config/nvim/init.lua \
		~/.config/nvim/lua \
		~/.config/kitty/kitty.conf \
		~/.config/rofi/config.rasi \
	; do \
		if [ -L "$$link" ]; then \
			target=$$(readlink "$$link"); \
			case "$$target" in \
				$(SKA_DIR)/config/*|$(SKA_CONFIG)/*) echo "  ✅ $$link → $$target" ;; \
				*) echo "  ⚠️  $$link → $$target (not pointing to $(SKA_DIR))"; ;; \
			esac; \
		elif [ -e "$$link" ]; then \
			echo "  ⚠️  $$link exists but is not a symlink"; \
		else \
			echo "  ❌ $$link missing"; \
			fail=1; \
		fi; \
	done; \
	if [ "$(WM_CHOICE)" = "hyprland" ]; then \
		for link in \
			~/.config/hypr/hyprland.conf \
			~/.config/hypr/hyprland-mode.conf \
			~/.config/hypr/hyprpaper.conf \
			~/.config/hypr/hyprlock.conf \
			~/.config/hypr/hypridle.conf \
			~/.config/waybar/config.jsonc \
			~/.config/waybar/style.css \
			~/.config/dunst/dunstrc \
		; do \
			if [ -L "$$link" ]; then \
				echo "  ✅ $$link"; \
			elif [ -e "$$link" ]; then \
				echo "  ⚠️  $$link exists but is not a symlink"; \
			else \
				echo "  ❌ $$link missing"; \
				fail=1; \
			fi; \
		done; \
	elif [ "$(WM_CHOICE)" = "i3" ]; then \
		for link in \
			~/.config/i3/config \
			~/.config/polybar/config.ini \
			~/.config/picom.conf \
		; do \
			if [ -L "$$link" ]; then \
				echo "  ✅ $$link"; \
			elif [ -e "$$link" ]; then \
				echo "  ⚠️  $$link exists but is not a symlink"; \
			else \
				echo "  ❌ $$link missing"; \
				fail=1; \
			fi; \
		done; \
	fi; \
	[ $$fail -eq 0 ] || { echo "FAIL: some symlinks are missing"; exit 1; }

test-wm: ## Validate WM choice and running environment
	@echo "── Testing WM environment ──"
	@if [ -z "$(WM_CHOICE)" ]; then \
		echo "  ⚠️  WM_CHOICE not set (run 'make prompt-wm-choice')"; \
	else \
		echo "  ✅ WM_CHOICE=$(WM_CHOICE)"; \
	fi
	@if [ "$(WM_CHOICE)" = "hyprland" ]; then \
		echo "  ✅ HYPR_MODE=$(HYPR_MODE)"; \
		if pgrep -x Hyprland >/dev/null 2>&1; then \
			echo "  ✅ Hyprland is running"; \
		else \
			echo "  ⚠️  Hyprland is not running"; \
		fi; \
	elif [ "$(WM_CHOICE)" = "i3" ]; then \
		if pgrep -x i3 >/dev/null 2>&1; then \
			echo "  ✅ i3 is running"; \
		else \
			echo "  ⚠️  i3 is not running"; \
		fi; \
	fi
