# test.mk - post-install smoke tests

.PHONY: test test-commands test-symlinks test-wm test-bar test-docker-static test-docs

test: validate-wm-choice test-commands test-symlinks test-wm test-bar test-docker-static test-docs ## Run local smoke tests
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
		~/.config/ghostty/config \
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
			~/.config/hypr/application-style.conf \
			~/.config/hypr/hyprland-mode.conf \
			~/.config/hypr/hyprpaper.conf \
			~/.config/hypr/hyprlock.conf \
			~/.config/hypr/hypridle.conf \
			~/.config/hypr/scripts/start-bar.sh \
			~/.config/waybar/config.jsonc \
			~/.config/waybar/style.css \
			~/.config/waybar/scripts \
			~/.config/swaync/config.json \
			~/.config/swaync/style.css \
			~/.config/qt6ct/qt6ct.conf \
			~/.config/qt6ct/colors/everforest-hard.conf \
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
			~/.config/polybar/launch.sh \
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

test-bar: ## Validate Hyprland bar selector script and persisted choice
	@echo "── Testing bar selector ──"
	@script="$(SKA_CONFIG)/hypr/scripts/start-bar.sh"; \
	if [ ! -f "$$script" ]; then \
		echo "  ❌ $$script missing"; \
		exit 1; \
	fi; \
	bash -n "$$script" || exit 1; \
	echo "  ✅ $$script syntax"; \
	tmp_home=$$(mktemp -d); \
	info_out=$$(mktemp); \
	invalid_err=$$(mktemp); \
	trap 'rm -rf "$$tmp_home" "$$info_out" "$$invalid_err"' EXIT; \
	HOME="$$tmp_home" SKA_BAR_DRY_RUN=1 bash "$$script" info >"$$info_out"; \
	grep -q "Current bar: waybar" "$$info_out" || { echo "  ❌ default bar should be waybar"; exit 1; }; \
	HOME="$$tmp_home" SKA_BAR_DRY_RUN=1 bash "$$script" switch quickshell >/dev/null || { echo "  ❌ switch quickshell failed"; exit 1; }; \
	[ "$$(cat "$$tmp_home/.config/skillarch/bar-choice")" = "quickshell" ] || { echo "  ❌ quickshell choice was not persisted"; exit 1; }; \
	HOME="$$tmp_home" SKA_BAR_DRY_RUN=1 bash "$$script" toggle >/dev/null || { echo "  ❌ toggle failed"; exit 1; }; \
	[ "$$(cat "$$tmp_home/.config/skillarch/bar-choice")" = "waybar" ] || { echo "  ❌ toggle should switch back to waybar"; exit 1; }; \
	if HOME="$$tmp_home" SKA_BAR_DRY_RUN=1 bash "$$script" switch invalid 2>"$$invalid_err"; then \
		echo "  ❌ invalid bar choice should fail"; \
		exit 1; \
	fi; \
	grep -q "invalid bar choice" "$$invalid_err" || { echo "  ❌ invalid bar choice should explain the error"; exit 1; }; \
	[ "$$(cat "$$tmp_home/.config/skillarch/bar-choice")" = "waybar" ] || { echo "  ❌ invalid switch changed persisted bar"; exit 1; }; \
	echo "  ✅ dry-run switch/toggle validation"; \
	if [ -f ~/.config/skillarch/bar-choice ]; then \
		choice=$$(cat ~/.config/skillarch/bar-choice); \
		case "$$choice" in \
			waybar) echo "  ✅ local bar-choice=waybar" ;; \
			quickshell) \
				echo "  ✅ local bar-choice=quickshell"; \
				[ -L ~/.config/quickshell ] || { echo "  ❌ ~/.config/quickshell missing for quickshell choice"; exit 1; } ;; \
			*) echo "  ❌ local bar-choice '$$choice' is invalid"; exit 1 ;; \
		esac; \
	else \
		echo "  ⚠️  ~/.config/skillarch/bar-choice missing (defaulting to waybar)"; \
	fi

test-docker-static: ## Validate Dockerfiles pin the expected WM choice
	@echo "── Testing Dockerfile WM selection ──"
	@fail=0; \
	if rg -q '/tmp/ska-wm-choice\.txt' $(SKA_DIR)/Dockerfile-full-i3 $(SKA_DIR)/Dockerfile-full-hyprland; then \
		echo "  ❌ Dockerfiles still use deprecated /tmp/ska-wm-choice.txt"; \
		fail=1; \
	else \
		echo "  ✅ Dockerfiles use ~/.config/skillarch/wm-choice"; \
	fi; \
	rg -q 'echo "i3" > ~/.config/skillarch/wm-choice' $(SKA_DIR)/Dockerfile-full-i3 || { echo "  ❌ Dockerfile-full-i3 does not persist i3 choice"; fail=1; }; \
	rg -q 'echo "hyprland" > ~/.config/skillarch/wm-choice' $(SKA_DIR)/Dockerfile-full-hyprland || { echo "  ❌ Dockerfile-full-hyprland does not persist hyprland choice"; fail=1; }; \
	[ $$fail -eq 0 ] || exit 1

test-docs: ## Validate WM/bar docs match the current implementation
	@echo "── Testing docs coherence ──"
	@fail=0; \
	if rg -n '/tmp/ska-wm-choice\.txt' $(SKA_DIR)/TESTING_GUIDE.md $(SKA_DIR)/WM_MIGRATION_GUIDE.md; then \
		echo "  ❌ stale WM choice path found in docs"; \
		fail=1; \
	else \
		echo "  ✅ docs use ~/.config/skillarch/wm-choice"; \
	fi; \
	if rg -n 'pick i3 at login' $(SKA_DIR)/readme.md; then \
		echo "  ❌ README still assumes an i3-only login flow"; \
		fail=1; \
	else \
		echo "  ✅ README no longer assumes i3-only login"; \
	fi; \
	[ $$fail -eq 0 ] || exit 1
