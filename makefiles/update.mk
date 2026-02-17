# update.mk - update

update: sanity-check ## Update SkillArch
	@[ -n "$$(git status --porcelain)" ] && echo "Error: git state is dirty, please "git stash" your changes before updating" && exit 1
	@[ "$$(git rev-parse --abbrev-ref HEAD)" != "main" ] && echo "Error: current branch is not main, please switch to main before updating" && exit 1
	@git pull
	@echo "SkillArch updated, please run make install to apply changes 🙏"
