# helpers.mk - sanity-check, symlink macros, clean

# Backup existing file then symlink
# Usage: $(call symlink,source,destination)
define symlink
	[ -f $(2) ] && [ ! -L $(2) ] && mv $(2) $(2).skabak || true
	ln -sf $(1) $(2)
endef

# Backup existing directory then symlink
# Usage: $(call symlink-dir,source,destination)
define symlink-dir
	[ -d $(2) ] && [ ! -L $(2) ] && mv $(2) $(2).skabak || true
	ln -sfn $(1) $(2)
endef

sanity-check:
	set -x
	@# Ensure we are in /opt/skillarch or /opt/skillarch-original (maintainer only)
	@[ "$$(pwd)" != "/opt/skillarch" ] && [ "$$(pwd)" != "/opt/skillarch-original" ] && echo "You must be in /opt/skillarch or /opt/skillarch-original to run this command" && exit 1
	@sudo id || (echo "Error: sudo access is required" ; exit 1)

clean: ## Clean up system and remove unnecessary files
	[ ! -f /.dockerenv ] && exit
	yes|sudo pacman -Scc
	yes|sudo pacman -Sc
	yes|sudo pacman -Rns $$(pacman -Qtdq) 2>/dev/null || true
	rm -rf ~/.cache/pip
	npm cache clean --force 2>/dev/null || true
	mise cache clear
	go clean -cache -modcache -i -r 2>/dev/null || true
	sudo rm -rf /var/cache/*
	rm -rf ~/.cache/*
	sudo rm -rf /tmp/*
	docker system prune -af 2>/dev/null || true
	sudo journalctl --vacuum-time=1d
	sudo find /var/log -type f -name "*.old" -delete
	sudo find /var/log -type f -name "*.gz" -delete
	sudo find /var/log -type f -exec truncate --size=0 {} \;
