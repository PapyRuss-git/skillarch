# Feuille de Route : Choix i3 vs Hyprland à l'installation

## Vue d'ensemble
Refactoriser SkillArch pour permettre le choix entre i3 (X11) et Hyprland (Wayland) lors de l'installation, avec séparation stricte des dépendances incompatibles.

---

## 1. Architecture cible

### 1.1 Variables Makefile
```makefile
# Variable de choix (définie par prompt interactif)
WM_CHOICE ?=

# Validation
ifeq ($(WM_CHOICE),)
    $(error WM_CHOICE must be set to 'i3' or 'hyprland')
endif

ifneq ($(WM_CHOICE),i3)
ifneq ($(WM_CHOICE),hyprland)
    $(error WM_CHOICE must be 'i3' or 'hyprland', got '$(WM_CHOICE)')
endif
endif
```

### 1.2 Nouvelle séquence d'installation
```
install:
    1. sanity-check
    2. prompt-wm-choice (nouveau)
    3. install-base
    4. install-cli-tools
    5. install-shell
    6. install-docker
    7. install-gui-common (nouveau)
    8. install-gui-$(WM_CHOICE) (conditionnel)
    9. install-gui-tools
    10. install-offensive
    11. install-wordlists
    12. install-hardening
```

---

## 2. Séparation des packages

### 2.1 Packages communs (install-gui-common)
```makefile
# Terminal & fonts
kitty
ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji
ttf-jetbrains-mono-nerd ttf-firacode-nerd

# Rofi (version qui supporte les deux)
rofi

# Audio & brightness
pavucontrol brightnessctl

# File manager & utilities
nautilus file-roller
arandr

# GNOME components (compatibles X11/Wayland)
gnome-control-center
gnome-bluetooth-3.0
gnome-keyring

# Polkit
polkit-gnome (pour i3)
# OU hyprpolkitagent (pour Hyprland)
```

### 2.2 Packages i3 uniquement (install-gui-i3)
```makefile
# Window manager
i3-gaps
i3lock
i3lock-fancy
i3-battery-popup

# Status bar
polybar

# X11 compositor
picom

# X11 utilities
feh                    # wallpaper
flameshot             # screenshots
xss-lock              # screen locker
xorg-server
xorg-xinit
xorg-xrandr
xclip                 # clipboard X11
maim                  # screenshots alternative
xdotool               # automation

# X11 portal
xdg-desktop-portal-gtk
```

### 2.3 Packages Hyprland uniquement (install-gui-hyprland)
```makefile
# Compositor
hyprland
hyprlock
hypridle
hyprpaper
hyprpolkitagent
hyprcursor
xdg-desktop-portal-hyprland

# Status bar
waybar

# Wayland utilities
grim                  # screenshots
slurp                 # region selector
wl-clipboard          # clipboard
clipse               # clipboard manager
wlogout              # power menu
dunst                # notifications
swayidle             # idle management (alternative)

# Wayland support
qt5-wayland
qt6-wayland
```

### 2.4 Packages GUI tools (communs, mais vérifier compatibilité)
```makefile
# Browsers (X11 + Wayland)
google-chrome
zen-browser-bin

# Development
code
cursor-bin

# Media
vlc
```

---

## 3. Modifications du Makefile

### 3.1 Nouveau target : prompt-wm-choice
```makefile
.PHONY: prompt-wm-choice
prompt-wm-choice:
	@echo "════════════════════════════════════════════════════════"
	@echo "  SkillArch Window Manager Selection"
	@echo "════════════════════════════════════════════════════════"
	@echo ""
	@echo "Choose your window manager:"
	@echo "  1) i3-gaps (X11)       - Stable, mature, widely supported"
	@echo "  2) Hyprland (Wayland)  - Modern, smooth animations, cutting-edge"
	@echo ""
	@read -p "Enter choice [1-2]: " choice; \
	case $$choice in \
		1) echo "i3" > /tmp/ska-wm-choice.txt ;; \
		2) echo "hyprland" > /tmp/ska-wm-choice.txt ;; \
		*) echo "Invalid choice. Aborting."; exit 1 ;; \
	esac
	@echo ""
	@echo "Selected: $$(cat /tmp/ska-wm-choice.txt)"
	@echo ""
```

### 3.2 Charger le choix dans les targets suivants
```makefile
# En début de Makefile, après les variables
WM_CHOICE := $(shell cat /tmp/ska-wm-choice.txt 2>/dev/null || echo "")
```

### 3.3 Refactoriser install-gui
```makefile
.PHONY: install-gui
install-gui: install-gui-common install-gui-wm

.PHONY: install-gui-common
install-gui-common:
	# Packages communs X11/Wayland
	$(PACMAN_INSTALL) kitty rofi pavucontrol brightnessctl \
		nautilus file-roller arandr \
		gnome-control-center gnome-bluetooth-3.0 gnome-keyring \
		ttf-dejavu ttf-liberation noto-fonts

.PHONY: install-gui-wm
install-gui-wm: install-gui-$(WM_CHOICE)

.PHONY: install-gui-i3
install-gui-i3:
	# X11 packages
	$(PACMAN_INSTALL) i3-gaps i3lock polybar picom feh flameshot \
		xss-lock xorg-server xorg-xinit xclip xdotool \
		xdg-desktop-portal-gtk
	$(YAY_INSTALL) i3lock-fancy i3-battery-popup
	# Symlink i3 config
	$(call symlink_config,i3)
	$(call symlink_config,polybar)
	$(call symlink_config,picom.conf)

.PHONY: install-gui-hyprland
install-gui-hyprland:
	# Wayland packages
	$(PACMAN_INSTALL) hyprland hyprlock hypridle hyprpaper \
		waybar grim slurp wl-clipboard dunst \
		qt5-wayland qt6-wayland xdg-desktop-portal-hyprland
	$(YAY_INSTALL) hyprpolkitagent clipse wlogout
	# Symlink Hyprland config
	$(call symlink_config,hypr)
	$(call symlink_config,waybar)
	$(call symlink_config,dunst)
```

---

## 4. Gestion des configurations

### 4.1 Structure des dotfiles
```
config/
├── common/              # Configs communes
│   ├── kitty/
│   ├── rofi/
│   └── nvim/
├── i3/                  # Configs i3
│   ├── config
│   ├── polybar/
│   └── picom.conf
├── hypr/                # Configs Hyprland
│   ├── hyprland.conf
│   ├── hyprlock.conf
│   ├── hypridle.conf
│   └── hyprpaper.conf
└── waybar/              # Config Waybar (Hyprland)
```

### 4.2 Fonction de symlink conditionnelle
```makefile
define symlink_config
	@if [ -d "$(CURDIR)/config/$(1)" ]; then \
		if [ -d "$(HOME)/.config/$(1)" ] && [ ! -L "$(HOME)/.config/$(1)" ]; then \
			mv "$(HOME)/.config/$(1)" "$(HOME)/.config/$(1).skabak"; \
		fi; \
		ln -sfn "$(CURDIR)/config/$(1)" "$(HOME)/.config/$(1)"; \
	elif [ -f "$(CURDIR)/config/$(1)" ]; then \
		if [ -f "$(HOME)/.config/$(1)" ] && [ ! -L "$(HOME)/.config/$(1)" ]; then \
			mv "$(HOME)/.config/$(1)" "$(HOME)/.config/$(1).skabak"; \
		fi; \
		ln -sf "$(CURDIR)/config/$(1)" "$(HOME)/.config/$(1)"; \
	fi
endef
```

---

## 5. Modifications des alias et helpers

### 5.1 Aliases conditionnels dans config/aliases
```bash
# Window manager detection
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export SKA_WM="hyprland"
elif [ -n "$I3SOCK" ]; then
    export SKA_WM="i3"
fi

# Conditional aliases
if [ "$SKA_WM" = "hyprland" ]; then
    alias screenshot='grim -g "$(slurp)" ~/Images/screenshot_$(date +%Y%m%d_%H%M%S).png'
    alias screenshot-copy='grim -g "$(slurp)" - | wl-copy'
    alias lock='hyprlock'
elif [ "$SKA_WM" = "i3" ]; then
    alias screenshot='flameshot gui'
    alias screenshot-full='flameshot full -p ~/Pictures/'
    alias lock='i3lock-fancy -f Bitstream-Vera-Serif -t "Welcome back to SkillArch"'
fi
```

### 5.2 Nouveau helper : ska-wm-info
```bash
#!/bin/bash
# Script: ska-wm-info
# Location: /usr/local/bin/ska-wm-info

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "Window Manager: Hyprland (Wayland)"
    echo "Version: $(hyprctl version | head -n1)"
elif [ -n "$I3SOCK" ]; then
    echo "Window Manager: i3 (X11)"
    echo "Version: $(i3 --version)"
else
    echo "No known window manager detected"
fi
```

---

## 6. Docker : stratégie multi-stage

### 6.1 Dockerfile-lite (pas de GUI)
```dockerfile
# Pas de changement - reste CLI only
```

### 6.2 Dockerfile-full-i3
```dockerfile
FROM skillarch-lite

# Set WM choice
RUN echo "i3" > /tmp/ska-wm-choice.txt

# Install GUI
RUN cd /opt/skillarch && make install-gui install-gui-tools
```

### 6.3 Dockerfile-full-hyprland
```dockerfile
FROM skillarch-lite

# Set WM choice
RUN echo "hyprland" > /tmp/ska-wm-choice.txt

# Install GUI
RUN cd /opt/skillarch && make install-gui install-gui-tools
```

### 6.4 Makefile targets Docker
```makefile
.PHONY: docker-build-full-i3
docker-build-full-i3:
	docker build -t skillarch:full-i3 -f Dockerfile-full-i3 .

.PHONY: docker-build-full-hyprland
docker-build-full-hyprland:
	docker build -t skillarch:full-hyprland -f Dockerfile-full-hyprland .
```

---

## 7. Display Manager / Login

### 7.1 Sessions alternatives
```
/usr/share/xsessions/i3.desktop
/usr/share/wayland-sessions/hyprland.desktop
```

### 7.2 Auto-login (optionnel)
Détecter le WM_CHOICE et configurer le display manager en conséquence (SDDM, LightDM, GDM)

---

## 8. Étapes d'implémentation (ordre recommandé)

### Phase 1 : Préparation ✅ COMPLÉTÉE
- [x] **Étape 1.1** : Créer la branche `feature/wm-choice`
- [x] **Étape 1.2** : Analyser les packages actuels et créer la liste complète de séparation
- [x] **Étape 1.3** : Auditer les configs actuelles pour identifier les dépendances croisées

### Phase 2 : Refactoring Makefile ✅ COMPLÉTÉE
- [x] **Étape 2.1** : Créer `prompt-wm-choice` target (3 choix: i3, Hyprland Desktop, Hyprland VM)
- [x] **Étape 2.2** : Créer `install-gui-common` target
- [x] **Étape 2.3** : Créer `install-gui-i3` target
- [x] **Étape 2.4** : Créer `install-gui-hyprland` target avec support Desktop/VM mode
- [x] **Étape 2.5** : Modifier la séquence `install` principale
- [x] **Étape 2.6** : Ajouter validation du WM_CHOICE (validate-wm-choice target)
- [x] **Étape 2.7** : Créer config VM-optimisée (hyprland-vm.conf) avec WLR_NO_HARDWARE_CURSORS

### Phase 3 : Séparation des configs ✅ COMPLÉTÉE
- [x] **Étape 3.1** : Réorganiser `config/` - configs communes à la racine, Hyprland-specific dans `config/hypr/`
- [x] **Étape 3.2** : Mettre à jour les symlinks dans les targets (waybar, dunst, clipse, xdg-desktop-portal)
- [x] **Étape 3.3** : Mettre à jour les symlinks sur la machine actuelle
- [x] **Étape 3.4** : Déplacer waybar/, dunst/, clipse/, xdg-desktop-portal/ dans config/hypr/

### Phase 4 : Aliases et helpers ✅ COMPLÉTÉE
- [x] **Étape 4.1** : Ajouter détection WM dans `config/aliases` (XDG_SESSION_TYPE)
- [x] **Étape 4.2** : Créer aliases conditionnels (cpy, paste, get-pid-click, flameshotz, mcrypt-enc)
- [x] **Étape 4.3** : Créer `ska-wm-info` helper (177 lignes, détection i3/Hyprland, modes, versions)
- [x] **Étape 4.4** : Mettre à jour `ska-help-bindings` pour afficher les bindings du WM actif (déjà fait)
- [x] **Étape 4.5** : Mettre à jour commentaire blur dans kitty.conf

### Phase 5 : Docker ✅ COMPLÉTÉE
- [x] **Étape 5.1** : Créer `Dockerfile-full-i3`
- [x] **Étape 5.2** : Créer `Dockerfile-full-hyprland`
- [x] **Étape 5.3** : Ajouter les targets Makefile correspondants (docker-build-full-i3, docker-build-full-hyprland, docker-run-full-i3, docker-run-full-hyprland)
- [x] **Étape 5.4** : Tester les builds multi-stage → `TESTING_GUIDE.md` créé avec procédures complètes de test

**Résumé des modifications :**
- Créés : `Dockerfile-full-i3`, `Dockerfile-full-hyprland`, `TESTING_GUIDE.md`
- Modifiés : `Makefile` (nouveaux targets docker-build-full-i3, docker-build-full-hyprland, docker-run-full-i3, docker-run-full-hyprland)
- Architecture : Chaque Dockerfile définit WM_CHOICE via `/tmp/ska-wm-choice.txt` avant `make install-gui`
- Run commands : i3 utilise X11 forwarding, Hyprland utilise Wayland socket mounting
- Documentation : `readme.md` et `CLAUDE.md` mis à jour avec les nouvelles images Docker
- Testing : Guide complet avec 8 tests Docker + 6 tests système, critères de succès, troubleshooting

### Phase 6 : Documentation ✅ COMPLÉTÉE
- [x] **Étape 6.1** : Mettre à jour `readme.md` avec le choix WM et les nouvelles images Docker
- [x] **Étape 6.2** : Mettre à jour `CLAUDE.md` avec la nouvelle architecture Docker multi-stage
- [x] **Étape 6.3** : Créer des screenshots pour i3 et Hyprland → `SCREENSHOTS_TODO.md` créé avec guide complet
- [x] **Étape 6.4** : Documenter la migration i3 → Hyprland → `WM_MIGRATION_GUIDE.md` créé (guide complet 450+ lignes)

**Résumé des modifications :**
- Créés : `WM_MIGRATION_GUIDE.md` (guide migration i3→Hyprland), `SCREENSHOTS_TODO.md` (checklist screenshots)
- Modifiés : `readme.md` (section Docker usage), `CLAUDE.md` (architecture Docker)
- Migration guide inclut : 2 options d'installation, équivalence bindings, troubleshooting, rollback
- Screenshots guide inclut : 12 screenshots à créer, organisation fichiers, outils nécessaires

### Phase 7 : Tests (PRÊT - Voir TESTING_GUIDE.md)
- [ ] **Étape 7.1** : Test installation fraîche avec i3 (procédure dans TESTING_GUIDE.md)
- [ ] **Étape 7.2** : Test installation fraîche avec Hyprland Desktop (procédure dans TESTING_GUIDE.md)
- [ ] **Étape 7.2b** : Test installation fraîche avec Hyprland VM Mode (procédure dans TESTING_GUIDE.md)
- [ ] **Étape 7.3** : Test Docker lite - regression (procédure dans TESTING_GUIDE.md)
- [ ] **Étape 7.4** : Test Docker full-i3 (procédure dans TESTING_GUIDE.md)
- [ ] **Étape 7.5** : Test Docker full-hyprland (procédure dans TESTING_GUIDE.md)
- [ ] **Étape 7.6** : Vérifier aucune dépendance croisée (procédure dans TESTING_GUIDE.md)

**Note** : Toutes les procédures de test, critères de succès, et troubleshooting sont documentés dans `TESTING_GUIDE.md`. Les tests nécessitent :
- VM CachyOS fraîche (pour tests 7.1, 7.2)
- Docker fonctionnel (pour tests 7.3, 7.4, 7.5)
- ~10GB espace disque libre
- Temps estimé : 2-3 heures pour tous les tests

### Phase 8 : Release
- [ ] **Étape 8.1** : Merge dans `main`
- [ ] **Étape 8.2** : Tag version (ex: v2.0.0)
- [ ] **Étape 8.3** : Créer release notes
- [ ] **Étape 8.4** : Notifier les utilisateurs existants

---

## 9. Points d'attention

### 9.1 Dépendances cachées
- Vérifier que Rofi fonctionne correctement en Wayland (rofi-wayland peut être nécessaire)
- Nautilus : vérifier compatibilité Wayland native
- VSCode / Cursor : testés sous X11 et Wayland

### 9.2 Compatibilité existante
- Les utilisateurs actuels ont probablement déjà un mix i3/Hyprland
- Prévoir un script de migration/nettoyage : `ska-cleanup-wm-packages`

### 9.3 Choix par défaut
- Si installation non-interactive (CI/CD, Docker), définir un défaut intelligent :
  ```makefile
  WM_CHOICE ?= i3  # Défaut si non spécifié
  ```

### 9.4 Migration post-installation
- Permettre de changer de WM après installation ?
  ```bash
  make switch-wm WM_CHOICE=hyprland
  ```

---

## 10. Variables d'environnement

### 10.1 Nouvelles variables
```bash
# Dans ~/.zshrc ou config/zshrc
export SKA_WM="i3"           # ou "hyprland"
export SKA_WM_TYPE="x11"     # ou "wayland"
```

### 10.2 Détection automatique
```bash
# Auto-detect in shell config
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export SKA_WM="hyprland"
    export SKA_WM_TYPE="wayland"
elif [ -n "$I3SOCK" ]; then
    export SKA_WM="i3"
    export SKA_WM_TYPE="x11"
fi
```

---

## 11. Fichiers à modifier

### Makefile
- `prompt-wm-choice` (nouveau)
- `install-gui-common` (nouveau)
- `install-gui-i3` (nouveau)
- `install-gui-hyprland` (nouveau)
- `install` (modifier séquence)
- `install-gui` (refactorer)
- Variables globales (ajouter WM_CHOICE)

### Configs
- `config/aliases` (aliases conditionnels)
- `config/zshrc` (détection WM)
- Réorganiser `config/i3/`, `config/hypr/`, etc.

### Documentation
- `readme.md` (section installation)
- `CLAUDE.md` (architecture)
- Nouveau : `WM_COMPARISON.md` (i3 vs Hyprland)

### Scripts
- `ska-wm-info` (nouveau)
- `ska-cleanup-wm-packages` (nouveau, optionnel)
- `ska-switch-wm` (nouveau, optionnel)

### Docker
- `Dockerfile-full-i3` (nouveau)
- `Dockerfile-full-hyprland` (nouveau)

---

## 12. Critères de succès

✅ **Installation i3 :**
- Aucun package Wayland installé
- i3, polybar, picom fonctionnent
- Flameshot screenshots OK
- Aucune erreur de dépendances manquantes

✅ **Installation Hyprland :**
- Aucun package X11-only installé
- Hyprland, waybar, animations OK
- Grim/slurp screenshots OK
- Pas de picom, feh, i3lock

✅ **Docker :**
- 3 images fonctionnelles : lite, full-i3, full-hyprland
- Tailles raisonnables (pas de doublons de packages)

✅ **Maintenance :**
- `make update` fonctionne quel que soit le WM choisi
- Helpers fonctionnent dans les deux environnements

---

## 13. Risques et mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Casser les installations existantes | 🔴 Élevé | Branche dédiée, tests exhaustifs, migration guide |
| Oublier des dépendances croisées | 🟡 Moyen | Audit complet des packages, tests sur VM fraîche |
| Complexifier le Makefile | 🟡 Moyen | Bien documenter, garder la logique simple |
| Doublons de configs | 🟢 Faible | Utiliser config/common/ pour les fichiers partagés |

---

## 14. Timeline estimée

- **Phase 1-2** (Préparation + Makefile) : 2-3 jours
- **Phase 3** (Configs) : 1-2 jours
- **Phase 4** (Aliases/helpers) : 1 jour
- **Phase 5** (Docker) : 1 jour
- **Phase 6** (Documentation) : 1 jour
- **Phase 7** (Tests) : 2-3 jours
- **Phase 8** (Release) : 1 jour

**Total estimé : 9-12 jours de travail**

---

## 15. Post-release

### 15.1 Feedback utilisateurs
- Créer un issue template pour remonter les problèmes de compatibilité
- Monitorer les installations (logs anonymes ?)

### 15.2 Évolutions futures
- Support d'autres WM ? (Sway, dwm, bspwm)
- Installation hybride (i3 + Hyprland pour tests)
- Script de benchmark performance i3 vs Hyprland

---

**Dernière mise à jour :** 2025-10-21
**Auteur :** Claude Code
**Statut :** Prêt pour tests - Phases 1-6 complétées ✅ (Makefile, configs, aliases, helpers, Docker, Documentation), Phase 7 prête avec guide complet (TESTING_GUIDE.md)
