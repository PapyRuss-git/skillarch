# security.mk - install-offensive, install-wordlists, install-hardening

install-offensive: sanity-check ## Install offensive tools
	yes|sudo pacman -S --noconfirm --needed metasploit fx lazygit fq gitleaks jdk21-openjdk burpsuite hashcat bettercap
	sudo sed -i 's#$JAVA_HOME#/usr/lib/jvm/java-21-openjdk#g' /usr/bin/burpsuite
	yay --noconfirm --needed -S ffuf gau pdtm-bin waybackurls fabric-ai-bin

	# Install Go security tools from list
	mise exec -- go version >/dev/null 2>&1 || { echo "ERROR: go not available via mise"; exit 1; }
	while IFS= read -r tool; do \
		[ -z "$$tool" ] || [ "$${tool#\#}" != "$$tool" ] && continue; \
		mise exec -- go install "$$tool" > /dev/null || echo "WARNING: go install $$tool failed"; \
	done < $(SKA_CONFIG)/lists/go-tools.txt
	zsh -c "source ~/.zshrc && pdtm -install-all -v"
	zsh -c "source ~/.zshrc && nuclei -update-templates -update-template-dir ~/.nuclei-templates"

	# Clone custom tools from list
	pushd /tmp
	while IFS='|' read -r name url; do \
		[ -z "$$name" ] || [ "$${name#\#}" != "$$name" ] && continue; \
		if [ ! -d /opt/$$name ]; then \
			git clone --depth=1 "$$url" && sudo mv "$$name" /opt/$$name \
			|| echo "WARNING: failed to clone $$name from $$url"; \
		fi; \
	done < $(SKA_CONFIG)/lists/clone-tools.txt
	popd
	make clean

install-wordlists: sanity-check ## Install wordlists
	[ ! -d /opt/lists ] && mkdir /tmp/lists && sudo mv /tmp/lists /opt/lists
	[ ! -f /opt/lists/rockyou.txt ] && curl -L https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -o /opt/lists/rockyou.txt
	# Clone wordlist repos from list
	while IFS='|' read -r name url; do \
		[ -z "$$name" ] || [ "$${name#\#}" != "$$name" ] && continue; \
		if [ ! -d /opt/lists/$$name ]; then \
			git clone --depth=1 "$$url" /opt/lists/$$name \
			|| echo "WARNING: failed to clone wordlist $$name from $$url"; \
		fi; \
	done < $(SKA_CONFIG)/lists/clone-wordlists.txt
	make clean

install-hardening: sanity-check ## Install hardening tools
	yes|sudo pacman -S --noconfirm --needed opensnitch
	# OPT-IN opensnitch as an egress firewall
	# sudo systemctl enable --now opensnitchd.service
	make clean
