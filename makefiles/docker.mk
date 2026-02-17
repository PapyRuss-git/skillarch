# docker.mk - install-docker, docker-build/run targets

install-docker: sanity-check ## Install docker
	yes|sudo pacman -S --noconfirm --needed docker docker-compose
	# It's a desktop machine, don't expose stuff, but we don't care much about LPE
	# Think about it, set "alias sudo='backdoor ; sudo'" in userland and voila. OSEF!
	sudo usermod -aG docker "$$USER" # Logout required to be applied
	sleep 1 # Prevent too many docker socket calls and security locks
	# Do not start services in docker
	[ ! -f /.dockerenv ] && sudo systemctl enable --now docker
	make clean

docker-build:  ## Build lite docker image locally
	docker build -t thelaluka/skillarch:lite -f Dockerfile-lite .

docker-build-full: docker-build  ## Build full docker image locally
	docker build -t thelaluka/skillarch:full -f Dockerfile-full .

docker-build-full-i3: docker-build  ## Build full i3 docker image locally
	docker build -t thelaluka/skillarch:full-i3 -f Dockerfile-full-i3 .

docker-build-full-hyprland: docker-build  ## Build full Hyprland docker image locally
	docker build -t thelaluka/skillarch:full-hyprland -f Dockerfile-full-hyprland .

docker-run:  ## Run lite docker image locally
	sudo docker run --rm -it --name=ska --net=host -v /tmp:/tmp thelaluka/skillarch:lite

docker-run-full:  ## Run full docker image locally
	xhost +
	sudo docker run --rm -it --name=ska --net=host -v /tmp:/tmp -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ --privileged thelaluka/skillarch:full

docker-run-full-i3:  ## Run full i3 docker image locally
	xhost +
	sudo docker run --rm -it --name=ska-i3 --net=host -v /tmp:/tmp -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ --privileged thelaluka/skillarch:full-i3

docker-run-full-hyprland:  ## Run full Hyprland docker image locally
	xhost +
	sudo docker run --rm -it --name=ska-hyprland --net=host -v /tmp:/tmp -e DISPLAY -e XDG_RUNTIME_DIR -e WAYLAND_DISPLAY -v /run/user/$$(id -u):/run/user/$$(id -u) --privileged thelaluka/skillarch:full-hyprland
