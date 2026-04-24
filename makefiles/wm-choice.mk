# wm-choice.mk - WM_CHOICE/HYPR_MODE variables, prompt, validate

# Window Manager Choice Variables (persisted in ~/.config/skillarch/)
SKA_CONFIG_DIR := $(HOME)/.config/skillarch
WM_CHOICE = $(shell cat $(HOME)/.config/skillarch/wm-choice 2>/dev/null || echo "")
HYPR_MODE = $(shell cat $(HOME)/.config/skillarch/hypr-mode 2>/dev/null || echo "desktop")

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
	@if [ "$(WM_CHOICE)" = "hyprland" ] && [ "$(HYPR_MODE)" != "desktop" ] && [ "$(HYPR_MODE)" != "vm" ]; then \
		echo "❌ ERROR: Invalid HYPR_MODE '$(HYPR_MODE)'. Must be 'desktop' or 'vm'."; \
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
