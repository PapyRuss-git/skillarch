.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c
.PHONY: help install

# Include all module makefiles
include makefiles/helpers.mk
include makefiles/wm-choice.mk
include makefiles/base.mk
include makefiles/shell.mk
include makefiles/docker.mk
include makefiles/gui-common.mk
include makefiles/gui-i3.mk
include makefiles/gui-hyprland.mk
include makefiles/gui-tools.mk
include makefiles/security.mk
include makefiles/update.mk
include makefiles/test.mk

help: ## Show this help message
	@echo 'Welcome to SkillArch! 🌹'
	@echo ''
	@echo 'Usage: make [target]'
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  %-18s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ''

install: prompt-wm-choice install-base install-cli-tools install-shell install-docker install-gui install-gui-tools install-offensive install-wordlists install-hardening clean ## Install SkillArch
	@echo "You are all set up! Enjoy ! 🌹"
