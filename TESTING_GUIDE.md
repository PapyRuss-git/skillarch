# Testing Guide - SkillArch WM Choice

Guide de test pour valider la fonctionnalité de choix Window Manager (i3/Hyprland) dans SkillArch.

---

## Phase 5.4 : Tests Docker Multi-Stage

### Prérequis
```bash
# Docker installé et fonctionnel
docker --version

# Espace disque suffisant (~10GB pour les images)
df -h /var/lib/docker

# Connexion Internet pour pull des images de base
```

---

## Test 1 : Build Dockerfile-full-i3

### Commande
```bash
cd /opt/skillarch
make docker-build-full-i3
```

### Critères de succès
✅ L'image de base `thelaluka/skillarch:lite` est téléchargée ou buildée
✅ Le fichier `/tmp/ska-wm-choice.txt` contient "i3"
✅ `make install-gui` détecte WM_CHOICE=i3
✅ Packages i3-specific installés : i3-gaps, polybar, picom, feh, flameshot, xclip
✅ Packages Hyprland NON installés : hyprland, waybar, grim, slurp, wl-clipboard
✅ Configuration i3 symlinkée : ~/.config/i3/, ~/.config/polybar/
✅ Image finale tagguée : `thelaluka/skillarch:full-i3`
✅ Taille image ~4GB

### Vérification post-build
```bash
# Vérifier que l'image existe
docker images | grep skillarch:full-i3

# Vérifier la taille
docker images thelaluka/skillarch:full-i3 --format "{{.Size}}"

# Tester l'image
docker run --rm thelaluka/skillarch:full-i3 bash -c "echo \$SKA_WM; which i3; which polybar"

# Vérifier que Hyprland n'est PAS installé
docker run --rm thelaluka/skillarch:full-i3 bash -c "which hyprland || echo 'OK: hyprland not found'"
```

### Output attendu
```
Building Dockerfile-full-i3...
Step 1/10 : FROM thelaluka/skillarch:lite
Step 2/10 : USER root
Step 3/10 : RUN echo "hacker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hacker
Step 4/10 : USER hacker
Step 5/10 : WORKDIR /opt/skillarch
Step 6/10 : RUN echo "i3" > /tmp/ska-wm-choice.txt
Step 7/10 : RUN make install-docker
Step 8/10 : RUN make install-gui
 ---> Running in xxxxx
[install-gui] WM_CHOICE detected: i3
Installing GUI common packages...
Installing i3-specific packages...
✓ i3-gaps installed
✓ polybar installed
✓ picom installed
...
Step 9/10 : RUN make install-gui-tools
Step 10/10 : RUN make install-wordlists
...
Successfully tagged thelaluka/skillarch:full-i3
```

---

## Test 2 : Build Dockerfile-full-hyprland

### Commande
```bash
cd /opt/skillarch
make docker-build-full-hyprland
```

### Critères de succès
✅ L'image de base `thelaluka/skillarch:lite` réutilisée (cache)
✅ Le fichier `/tmp/ska-wm-choice.txt` contient "hyprland"
✅ `make install-gui` détecte WM_CHOICE=hyprland
✅ Packages Hyprland installés : hyprland, waybar, grim, slurp, wl-clipboard, clipse
✅ Packages i3 NON installés : i3-gaps, polybar, picom, feh, flameshot
✅ Configuration Hyprland symlinkée : ~/.config/hypr/, ~/.config/waybar/
✅ Image finale tagguée : `thelaluka/skillarch:full-hyprland`
✅ Taille image ~4GB

### Vérification post-build
```bash
# Vérifier que l'image existe
docker images | grep skillarch:full-hyprland

# Vérifier la taille
docker images thelaluka/skillarch:full-hyprland --format "{{.Size}}"

# Tester l'image
docker run --rm thelaluka/skillarch:full-hyprland bash -c "echo \$SKA_WM; which hyprland; which waybar"

# Vérifier que i3 n'est PAS installé
docker run --rm thelaluka/skillarch:full-hyprland bash -c "which i3 || echo 'OK: i3 not found'"
```

### Output attendu
```
Building Dockerfile-full-hyprland...
Step 1/10 : FROM thelaluka/skillarch:lite
Step 2/10 : USER root
Step 3/10 : RUN echo "hacker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hacker
Step 4/10 : USER hacker
Step 5/10 : WORKDIR /opt/skillarch
Step 6/10 : RUN echo "hyprland" > /tmp/ska-wm-choice.txt
Step 7/10 : RUN make install-docker
Step 8/10 : RUN make install-gui
 ---> Running in xxxxx
[install-gui] WM_CHOICE detected: hyprland
Installing GUI common packages...
Installing Hyprland-specific packages...
✓ hyprland installed
✓ waybar installed
✓ grim installed
...
Step 9/10 : RUN make install-gui-tools
Step 10/10 : RUN make install-wordlists
...
Successfully tagged thelaluka/skillarch:full-hyprland
```

---

## Test 3 : Comparer les tailles d'images

### Commande
```bash
docker images | grep skillarch | awk '{print $1":"$2, $7}' | column -t
```

### Résultats attendus
```
thelaluka/skillarch:lite              ~2GB
thelaluka/skillarch:full              ~5GB  (legacy, both WM)
thelaluka/skillarch:full-i3           ~4GB
thelaluka/skillarch:full-hyprland     ~4GB
```

### Analyse
- `full` est plus gros car contient i3 ET Hyprland (conflits)
- `full-i3` et `full-hyprland` sont similaires (~4GB) car packages GUI équivalents
- Les deux images séparées économisent ~1GB par rapport à `full` legacy

---

## Test 4 : Vérifier l'isolation des packages

### Test i3 : Packages Wayland absents
```bash
docker run --rm thelaluka/skillarch:full-i3 bash -c "
  pacman -Q | grep -E '(hyprland|waybar|grim|slurp|wl-clipboard)' && echo 'FAIL: Wayland packages found' || echo 'PASS: No Wayland packages'
"
```

Attendu : `PASS: No Wayland packages`

### Test Hyprland : Packages X11-only absents
```bash
docker run --rm thelaluka/skillarch:full-hyprland bash -c "
  pacman -Q | grep -E '(i3-gaps|polybar|picom|feh|flameshot)' && echo 'FAIL: X11-only packages found' || echo 'PASS: No X11-only packages'
"
```

Attendu : `PASS: No X11-only packages`

---

## Test 5 : Runtime - Docker run i3

### Commande
```bash
make docker-run-full-i3
```

### Critères de succès
✅ Container démarre sans erreur
✅ X11 forwarding fonctionne (DISPLAY envvar présent)
✅ `/tmp/.X11-unix` monté
✅ `ska-wm-info` détecte "i3" (ou "unknown" si pas de X11 host)
✅ Commandes i3-specific disponibles : i3-msg, polybar, flameshot

### Test interactif
```bash
# Dans le container
ska-wm-info
which i3 polybar picom flameshot
echo $DISPLAY
ls -la /tmp/.X11-unix/
```

---

## Test 6 : Runtime - Docker run Hyprland

### Commande
```bash
make docker-run-full-hyprland
```

### Critères de succès
✅ Container démarre sans erreur
✅ Wayland env vars présents (XDG_RUNTIME_DIR, WAYLAND_DISPLAY)
✅ Socket Wayland monté (`/run/user/$(id -u)`)
✅ `ska-wm-info` détecte "hyprland" (ou "unknown" si pas de Wayland host)
✅ Commandes Hyprland-specific disponibles : hyprctl, waybar, grim, slurp

### Test interactif
```bash
# Dans le container
ska-wm-info
which hyprland waybar grim slurp wl-copy
echo $WAYLAND_DISPLAY
echo $XDG_RUNTIME_DIR
ls -la $XDG_RUNTIME_DIR/ | grep wayland
```

### Note importante
⚠️ Hyprland en Docker nécessite un host Wayland. Sur un host X11, Hyprland ne pourra pas démarrer (normal).

---

## Test 7 : Validation Makefile targets

### Test help output
```bash
make help | grep docker
```

Attendu :
```
docker-build              Build lite docker image locally
docker-build-full         Build full docker image locally
docker-build-full-i3      Build full i3 docker image locally
docker-build-full-hyprland Build full Hyprland docker image locally
docker-run                Run lite docker image locally
docker-run-full           Run full docker image locally
docker-run-full-i3        Run full i3 docker image locally
docker-run-full-hyprland  Run full Hyprland docker image locally
```

### Test dependency chain
```bash
# Vérifier que docker-build-full-i3 dépend de docker-build
grep -A 1 "docker-build-full-i3:" Makefile
```

Attendu :
```makefile
docker-build-full-i3: docker-build  ## Build full i3 docker image locally
	docker build -t thelaluka/skillarch:full-i3 -f Dockerfile-full-i3 .
```

---

## Test 8 : Validation syntaxe Dockerfiles

### Test Dockerfile-full-i3
```bash
docker build --check -f Dockerfile-full-i3 . || docker build --dry-run -f Dockerfile-full-i3 .
```

### Test Dockerfile-full-hyprland
```bash
docker build --check -f Dockerfile-full-hyprland . || docker build --dry-run -f Dockerfile-full-hyprland .
```

Si `--check` ou `--dry-run` ne sont pas supportés, faire un build jusqu'à la première étape :
```bash
docker build -f Dockerfile-full-i3 --target 1 . 2>&1 | head -20
```

---

## Phase 7 : Tests Installation Système

### Test 7.1 : Installation fraîche avec i3

**Environnement** : VM CachyOS fraîche ou chroot

#### Étapes
```bash
# 1. Cloner SkillArch
git clone https://github.com/laluka/skillarch /opt/skillarch
cd /opt/skillarch

# 2. Lancer l'installation
make install

# 3. Au prompt, choisir "1) i3-gaps (X11)"

# 4. Vérifier l'installation
pacman -Q | grep -E '(i3-gaps|polybar|picom)'
ls -la ~/.config/i3/
ls -la ~/.config/polybar/

# 5. Redémarrer et tester
sudo reboot
# Au login, sélectionner "i3"
# Tester : $mod+Return (terminal), $mod+d (rofi)
```

#### Critères de succès
✅ Prompt WM choice s'affiche correctement
✅ i3 et dépendances installés
✅ Hyprland NON installé
✅ Configs symlinkées correctement
✅ i3 démarre après reboot
✅ Bindings fonctionnels
✅ Polybar affichée
✅ Rofi fonctionne

---

### Test 7.2 : Installation fraîche avec Hyprland

**Environnement** : VM CachyOS fraîche ou chroot

#### Étapes
```bash
# 1. Cloner SkillArch
git clone https://github.com/laluka/skillarch /opt/skillarch
cd /opt/skillarch

# 2. Lancer l'installation
make install

# 3. Au prompt, choisir "2) Hyprland (Desktop)" ou "3) Hyprland (VM Mode)"

# 4. Vérifier l'installation
pacman -Q | grep -E '(hyprland|waybar|grim)'
ls -la ~/.config/hypr/
ls -la ~/.config/waybar/

# 5. Redémarrer et tester
sudo reboot
# Au login, sélectionner "Hyprland"
# Tester : $mod+Return (terminal), $mod+D (rofi)
```

#### Critères de succès
✅ Prompt WM choice s'affiche avec 3 options
✅ Hyprland et dépendances installés
✅ i3 NON installé
✅ Configs symlinkées correctement (hypr/, waybar/, dunst/)
✅ Hyprland démarre après reboot
✅ Bindings fonctionnels
✅ Waybar affichée
✅ Rofi fonctionne en mode Wayland

---

### Test 7.3 : Docker lite (validation regression)

#### Commande
```bash
make docker-build
make docker-run
```

#### Critères de succès
✅ Build réussit (image ~2GB)
✅ Container démarre
✅ CLI tools présents : burpsuite, metasploit, nmap, etc.
✅ AUCUN package GUI installé
✅ Shell zsh fonctionne
✅ Offensive tools accessibles

---

### Test 7.6 : Vérifier absence dépendances croisées

#### Sur installation i3
```bash
# Depuis une installation i3
pacman -Q | grep -E '(hyprland|waybar|wl-clipboard|grim|slurp|clipse|wlogout|hypridle|hyprlock|hyprpaper|hyprpolkitagent)'

# Attendu : Aucun résultat (ou juste des dépendances communes comme qt5/qt6-wayland pour certaines apps)
```

#### Sur installation Hyprland
```bash
# Depuis une installation Hyprland
pacman -Q | grep -E '(i3-gaps|i3lock|i3lock-fancy|i3-battery-popup|polybar|picom|feh|flameshot|xss-lock)'

# Attendu : Aucun résultat (ou juste xorg-xwayland pour rétrocompatibilité)
```

#### Acceptable
- `xorg-xwayland` peut être présent sur Hyprland (nécessaire pour apps X11)
- `qt5-wayland`, `qt6-wayland` peuvent être présents sur i3 (apps Qt modernes)
- `rofi` présent sur les deux (supporte X11 et Wayland)

#### NON acceptable
- `i3-gaps` + `hyprland` ensemble
- `polybar` + `waybar` ensemble
- `picom` sur Hyprland (compositing intégré)
- `xdg-desktop-portal-gtk` + `xdg-desktop-portal-hyprland` ensemble (conflit)

---

## Checklist complète des tests

### Phase 5.4 : Tests Docker
- [ ] Test 1 : Build Dockerfile-full-i3
- [ ] Test 2 : Build Dockerfile-full-hyprland
- [ ] Test 3 : Comparer tailles images
- [ ] Test 4 : Vérifier isolation packages
- [ ] Test 5 : Runtime i3 container
- [ ] Test 6 : Runtime Hyprland container
- [ ] Test 7 : Validation Makefile targets
- [ ] Test 8 : Validation syntaxe Dockerfiles

### Phase 7 : Tests Installation
- [ ] Test 7.1 : Installation fraîche i3
- [ ] Test 7.2 : Installation fraîche Hyprland Desktop
- [ ] Test 7.2b : Installation fraîche Hyprland VM
- [ ] Test 7.3 : Docker lite (regression)
- [ ] Test 7.6 : Dépendances croisées i3
- [ ] Test 7.6 : Dépendances croisées Hyprland

---

## Problèmes connus et solutions

### Build Docker échoue : "Cannot connect to Docker daemon"
```bash
# Vérifier que Docker tourne
sudo systemctl status docker
sudo systemctl start docker

# Vérifier les permissions
sudo usermod -aG docker $USER
# Logout/login requis
```

### Build Docker échoue : "No space left on device"
```bash
# Nettoyer les images/containers inutilisés
docker system prune -af

# Vérifier l'espace
df -h /var/lib/docker
```

### L'image lite n'existe pas localement
```bash
# Deux options :
# 1. Puller depuis Docker Hub
docker pull thelaluka/skillarch:lite

# 2. Builder localement d'abord
make docker-build
```

---

## Documentation de test

Pour marquer un test comme réussi, documenter :
1. **Date du test**
2. **Environnement** (OS, Docker version, hardware)
3. **Commande exacte**
4. **Output complet** (ou extrait significatif)
5. **Résultat** : ✅ PASS ou ❌ FAIL
6. **Notes** : Problèmes rencontrés, temps d'exécution, etc.

### Template
```markdown
## Test : Build Dockerfile-full-i3
**Date** : 2025-10-21
**Environnement** : CachyOS, Docker 28.5.1, 16GB RAM
**Commande** : `make docker-build-full-i3`
**Durée** : 12 minutes
**Résultat** : ✅ PASS

**Output** :
```
Step 8/10 : RUN make install-gui
[install-gui] WM_CHOICE detected: i3
Installing i3-specific packages...
✓ i3-gaps installed
...
Successfully tagged thelaluka/skillarch:full-i3
```

**Notes** : Build réussi du premier coup. Image finale 3.8GB.
```

---

**Dernière mise à jour** : 2025-10-21
**Version** : 1.0
**Auteur** : Claude Code
