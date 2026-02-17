# security.mk - install-offensive, install-wordlists, install-hardening

install-offensive: sanity-check ## Install offensive tools
	yes|sudo pacman -S --noconfirm --needed metasploit fx lazygit fq gitleaks jdk21-openjdk burpsuite hashcat bettercap
	sudo sed -i 's#$JAVA_HOME#/usr/lib/jvm/java-21-openjdk#g' /usr/bin/burpsuite
	yay --noconfirm --needed -S ffuf gau pdtm-bin waybackurls fabric-ai-bin

	# Hide stdout and Keep stderr for CI builds
	mise exec -- go install github.com/sw33tLie/sns@latest > /dev/null
	mise exec -- go install github.com/glitchedgitz/cook/v2/cmd/cook@latest > /dev/null
	mise exec -- go install github.com/x90skysn3k/brutespray@latest > /dev/null
	mise exec -- go install github.com/sensepost/gowitness@latest > /dev/null
	mise exec -- go version >/dev/null 2>&1 || { echo "ERROR: go not available via mise"; exit 1; }
	zsh -c "source ~/.zshrc && pdtm -install-all -v"
	zsh -c "source ~/.zshrc && nuclei -update-templates -update-template-dir ~/.nuclei-templates"

	# Clone custom tools
	pushd /tmp # Avoid git clone --depth=1 in root
	[ ! -d /opt/chisel ] && git clone --depth=1 https://github.com/jpillora/chisel && sudo mv chisel /opt/chisel
	[ ! -d /opt/phpggc ] && git clone --depth=1 https://github.com/ambionics/phpggc && sudo mv phpggc /opt/phpggc
	[ ! -d /opt/PyFuscation ] && git clone --depth=1 https://github.com/CBHue/PyFuscation && sudo mv PyFuscation /opt/PyFuscation
	[ ! -d /opt/CloudFlair ] && git clone --depth=1 https://github.com/christophetd/CloudFlair && sudo mv CloudFlair /opt/CloudFlair
	[ ! -d /opt/minos-static ] && git clone --depth=1 https://github.com/minos-org/minos-static && sudo mv minos-static /opt/minos-static
	[ ! -d /opt/exploit-database ] && git clone --depth=1 https://github.com/offensive-security/exploit-database && sudo mv exploit-database /opt/exploit-database
	[ ! -d /opt/exploitdb ] && git clone --depth=1 https://gitlab.com/exploit-database/exploitdb && sudo mv exploitdb /opt/exploitdb
	[ ! -d /opt/pty4all ] && git clone --depth=1 https://github.com/laluka/pty4all && sudo mv pty4all /opt/pty4all
	[ ! -d /opt/pypotomux ] && git clone --depth=1 https://github.com/laluka/pypotomux && sudo mv pypotomux /opt/pypotomux
	popd
	make clean

install-wordlists: sanity-check ## Install wordlists
	[ ! -d /opt/lists ] && mkdir /tmp/lists && sudo mv /tmp/lists /opt/lists
	[ ! -f /opt/lists/rockyou.txt ] && curl -L https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -o /opt/lists/rockyou.txt
	[ ! -d /opt/lists/PayloadsAllTheThings ] && git clone --depth=1 https://github.com/swisskyrepo/PayloadsAllTheThings /opt/lists/PayloadsAllTheThings
	[ ! -d /opt/lists/BruteX ] && git clone --depth=1 https://github.com/1N3/BruteX /opt/lists/BruteX
	[ ! -d /opt/lists/IntruderPayloads ] && git clone --depth=1 https://github.com/1N3/IntruderPayloads /opt/lists/IntruderPayloads
	[ ! -d /opt/lists/Probable-Wordlists ] && git clone --depth=1 https://github.com/berzerk0/Probable-Wordlists /opt/lists/Probable-Wordlists
	[ ! -d /opt/lists/Open-Redirect-Payloads ] && git clone --depth=1 https://github.com/cujanovic/Open-Redirect-Payloads /opt/lists/Open-Redirect-Payloads
	[ ! -d /opt/lists/SecLists ] && git clone --depth=1 https://github.com/danielmiessler/SecLists /opt/lists/SecLists
	[ ! -d /opt/lists/Pwdb-Public ] && git clone --depth=1 https://github.com/ignis-sec/Pwdb-Public /opt/lists/Pwdb-Public
	[ ! -d /opt/lists/Bug-Bounty-Wordlists ] && git clone --depth=1 https://github.com/Karanxa/Bug-Bounty-Wordlists /opt/lists/Bug-Bounty-Wordlists
	[ ! -d /opt/lists/richelieu ] && git clone --depth=1 https://github.com/tarraschk/richelieu /opt/lists/richelieu
	[ ! -d /opt/lists/webapp-wordlists ] && git clone --depth=1 https://github.com/p0dalirius/webapp-wordlists /opt/lists/webapp-wordlists
	make clean

install-hardening: sanity-check ## Install hardening tools
	yes|sudo pacman -S --noconfirm --needed opensnitch
	# OPT-IN opensnitch as an egress firewall
	# sudo systemctl enable --now opensnitchd.service
	make clean
