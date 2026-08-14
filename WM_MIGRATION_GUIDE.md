# Guide de Migration : i3 → Hyprland

Ce guide vous aidera à migrer votre installation SkillArch d'i3 (X11) vers Hyprland (Wayland).

> **⚠️ Note (août 2026)** : depuis Hyprland 0.55, la configuration est au format **Lua**
> (`~/.config/hypr/hyprland.lua`, overrides de mode dans `~/.config/hypr/hyprland-mode.lua`,
> moniteurs locaux dans `~/.config/hypr/monitors.lua`). Les extraits de ce guide qui
> référencent `hyprland.conf` / `hyprland-vm.conf` décrivent l'ancien format hyprlang,
> déprécié — la sélection desktop/VM se fait désormais via `make install` (`HYPR_MODE`).

---

## Avant de Commencer

### ⚠️ Prérequis
- ✅ Sauvegarde de votre configuration i3 actuelle
- ✅ Session i3 fonctionnelle (pour revenir en arrière si besoin)
- ✅ Connexion Internet stable
- ✅ Au moins 2GB d'espace disque libre

### 🔍 Vérifier votre système actuel
```bash
# Vérifier le WM actif
ska-wm-info

# Vérifier les packages i3 installés
pacman -Q | grep -E '(i3-|polybar|picom|feh|flameshot)'

# Sauvegarder vos configs personnelles (si vous en avez)
cp ~/.config/i3/config ~/.config/i3/config.backup.$(date +%Y%m%d)
cp ~/.config/polybar/config.ini ~/.config/polybar/config.ini.backup.$(date +%Y%m%d)
```

---

## Option 1 : Installation propre (Recommandé)

### Étape 1 : Désinstaller i3 et ses dépendances X11

⚠️ **IMPORTANT** : Effectuez cette opération depuis un terminal TTY (Ctrl+Alt+F2) ou depuis GNOME, PAS depuis i3 !

```bash
# Passer en TTY (si vous êtes dans i3)
# Appuyez sur Ctrl+Alt+F2

# Se connecter et exécuter :
sudo pacman -Rns i3-gaps i3lock i3lock-fancy i3-battery-popup polybar picom \
    feh flameshot xss-lock maim xdotool xdg-desktop-portal-gtk

# Revenir en interface graphique
# Ctrl+Alt+F1 (ou F7)
```

### Étape 2 : Installer Hyprland

```bash
cd /opt/skillarch

# Définir le choix WM
mkdir -p ~/.config/skillarch && echo "hyprland" > ~/.config/skillarch/wm-choice

# Installer Hyprland et ses composants
make install-gui

# Redémarrer
sudo reboot
```

### Étape 3 : Sélectionner Hyprland au login

Au login screen :
1. Cliquer sur l'icône de session (en bas à gauche ou en haut à droite selon le display manager)
2. Sélectionner **"Hyprland"**
3. Se connecter

---

## Option 2 : Installation parallèle (Pour tester)

Cette option garde i3 ET Hyprland installés (possibilité de conflits de packages).

```bash
cd /opt/skillarch

# Définir le choix WM pour Hyprland
mkdir -p ~/.config/skillarch && echo "hyprland" > ~/.config/skillarch/wm-choice

# Installer Hyprland sans désinstaller i3
make install-gui-hyprland

# Redémarrer
sudo reboot
```

Au login, vous pouvez choisir entre i3 et Hyprland dans le sélecteur de session.

⚠️ **Note** : Cette approche peut créer des conflits de packages (xdg-desktop-portal-gtk vs xdg-desktop-portal-hyprland, polkit-gnome vs hyprpolkitagent, etc.).

---

## Différences Clés : i3 vs Hyprland

### Architecture
| Aspect | i3 | Hyprland |
|--------|----|-----------|
| **Protocole** | X11 | Wayland |
| **Type** | Window Manager | Compositor |
| **Animations** | Aucune | Fluides et configurables |
| **Performance** | Stable | Plus moderne, GPU-accelerated |
| **Maturité** | Très mature (~15 ans) | Récent (~2 ans) |

### Outils remplacés

| i3 (X11) | Hyprland (Wayland) |
|----------|--------------------|
| `polybar` | `waybar` |
| `picom` | Intégré dans Hyprland |
| `feh` | `hyprpaper` |
| `flameshot` | `grim` + `slurp` |
| `i3lock` | `hyprlock` |
| `xss-lock` | `hypridle` |
| `xclip` | `wl-clipboard` |
| `rofi` | `rofi` (mode Wayland) |
| `dunst` (optionnel) | `dunst` (fonctionne aussi) |
| `arandr` | Config Hyprland directe |
| `polkit-gnome` | `hyprpolkitagent` |

---

## Équivalence des Bindings

### Bindings de base

| Action | i3 | Hyprland |
|--------|----|-----------|
| Ouvrir terminal | `$mod+Return` | `$mod+Return` |
| Fermer fenêtre | `$mod+Shift+q` | `$mod+Shift+Q` |
| Launcher | `$mod+d` | `$mod+D` |
| Fullscreen | `$mod+f` | `$mod+F` |
| Floating toggle | `$mod+Shift+space` | `$mod+V` |
| Reload config | `$mod+Shift+r` | `$mod+Shift+R` |
| Quitter WM | `$mod+Shift+e` | `$mod+Shift+E` |

### Navigation

| Action | i3 | Hyprland |
|--------|----|-----------|
| Focus gauche | `$mod+j` | `$mod+left` |
| Focus droite | `$mod+;` | `$mod+right` |
| Focus haut | `$mod+k` | `$mod+up` |
| Focus bas | `$mod+l` | `$mod+down` |
| Move gauche | `$mod+Shift+j` | `$mod+Shift+left` |
| Move droite | `$mod+Shift+;` | `$mod+Shift+right` |

### Workspaces

| Action | i3 | Hyprland |
|--------|----|-----------|
| Switch workspace 1-10 | `$mod+[1-9,0]` | `$mod+[1-9,0]` |
| Move to workspace | `$mod+Shift+[1-9,0]` | `$mod+Shift+[1-9,0]` |

### Screenshots

| Action | i3 | Hyprland |
|--------|----|-----------|
| Screenshot zone | `flameshot gui` | `grim -g "$(slurp)"` |
| Alias | `flameshotz` | `flameshotz` (détecté auto) |

---

## Aliases conditionnels (déjà configurés)

SkillArch détecte automatiquement votre WM et adapte les aliases :

```bash
# Ces commandes fonctionnent dans les deux environnements :
cpy         # Copier dans le presse-papier (xclip ou wl-copy)
paste       # Coller depuis le presse-papier (xclip ou wl-paste)
screenshot  # Prendre un screenshot
lock        # Verrouiller l'écran (i3lock ou hyprlock)

# Vérifier quel WM est actif
ska-wm-info

# Voir les bindings du WM actif
ska-help-bindings
```

---

## Configuration Hyprland

### Fichiers de configuration

Hyprland utilise plusieurs fichiers dans `~/.config/hypr/` :

```
~/.config/hypr/
├── hyprland.conf         # Config principale (Desktop)
├── hyprland-vm.conf      # Config VM-optimisée
├── hyprlock.conf         # Lockscreen
├── hypridle.conf         # Idle management
└── hyprpaper.conf        # Wallpaper
```

### Configs associées

```
~/.config/waybar/         # Status bar
~/.config/dunst/          # Notifications
~/.config/clipse/         # Clipboard manager
~/.config/rofi/           # Launcher (partagé i3/Hyprland)
```

### Personnalisation de base

#### Changer le wallpaper
```bash
# Éditer hyprpaper.conf
vim ~/.config/hypr/hyprpaper.conf

# Modifier la ligne :
wallpaper = ,/opt/skillarch/assets/everforest-bg.jpg
# Remplacer par votre image

# Recharger hyprpaper
killall hyprpaper && hyprpaper &
```

#### Modifier les bindings
```bash
# Éditer hyprland.conf
vim ~/.config/hypr/hyprland.conf

# Chercher la section "BINDINGS"
# Format : bind = MOD, key, action, params

# Exemple : changer le terminal
bind = SUPER, Return, exec, kitty

# Recharger la config
hyprctl reload
```

#### Personnaliser waybar
```bash
# Éditer le style CSS
vim ~/.config/waybar/style.css

# Éditer la config JSON
vim ~/.config/waybar/config

# Redémarrer waybar
killall waybar && waybar &
```

---

## Mode VM : Différences importantes

Si vous utilisez SkillArch dans une VM, utilisez la config VM-optimisée :

```bash
# Utiliser la config VM au lieu de Desktop
ln -sf /opt/skillarch/config/hypr/hyprland-vm.conf ~/.config/hypr/hyprland.conf

# Ou lors de l'installation :
# Choisir "2) Hyprland (VM Mode)" dans le prompt
```

### Optimisations VM incluses :
- `WLR_NO_HARDWARE_CURSORS=1` (fix curseur invisible)
- Animations désactivées/réduites
- Effets visuels minimisés
- Meilleure performance sur hyperviseurs

---

## Problèmes Courants et Solutions

### 1. Curseur invisible dans VM

**Symptôme** : Le curseur n'apparaît pas dans VirtualBox/VMware

**Solution** :
```bash
# Vérifier que vous utilisez la config VM
cat ~/.config/hypr/hyprland.conf | grep WLR_NO_HARDWARE_CURSORS

# Si absent, utiliser la config VM
ln -sf /opt/skillarch/config/hypr/hyprland-vm.conf ~/.config/hypr/hyprland.conf
```

### 2. Applications ne se lancent pas

**Symptôme** : Certaines apps X11 ne fonctionnent pas sous Wayland

**Solution** :
```bash
# Installer XWayland (normalement déjà installé)
sudo pacman -S xorg-xwayland

# Forcer X11 pour une app spécifique
GDK_BACKEND=x11 firefox
```

### 3. Clipboard ne fonctionne pas

**Symptôme** : Copier/coller ne fonctionne pas entre apps

**Solution** :
```bash
# Démarrer clipse (clipboard manager)
clipse -listen

# Ou redémarrer Hyprland
$mod+Shift+R
```

### 4. Waybar ne s'affiche pas

**Symptôme** : La barre de status est absente

**Solution** :
```bash
# Vérifier si waybar tourne
pgrep waybar

# Le relancer
killall waybar && waybar &

# Vérifier les logs
journalctl --user -u waybar -f
```

### 5. Écran noir au démarrage

**Symptôme** : Écran noir après login Hyprland

**Solution** :
```bash
# Passer en TTY (Ctrl+Alt+F2)
# Vérifier les logs
journalctl --user -b | grep -i hyprland

# Tester Hyprland en verbose
Hyprland -c ~/.config/hypr/hyprland.conf
```

### 6. Moniteurs multiples non détectés

**Symptôme** : Seul un écran fonctionne

**Solution** :
```bash
# Lister les moniteurs
hyprctl monitors

# Configurer dans hyprland.conf
vim ~/.config/hypr/hyprland.conf

# Ajouter :
# monitor=DP-1,1920x1080@60,0x0,1
# monitor=HDMI-A-1,1920x1080@60,1920x0,1

# Recharger
hyprctl reload
```

---

## Fonctionnalités Hyprland à explorer

### 1. Animations personnalisables
```bash
# Dans hyprland.conf
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = fade, 1, 7, default
}
```

### 2. Window rules
```bash
# Float automatique pour certaines apps
windowrule = float, ^(pavucontrol)$
windowrule = float, ^(nm-connection-editor)$

# Workspace dédié
windowrule = workspace 2, ^(firefox)$
```

### 3. Gestures touchpad
```bash
gestures {
    workspace_swipe = on
    workspace_swipe_fingers = 3
}
```

### 4. Dispatchers avancés
```bash
# Bind pour actions complexes
bind = SUPER, G, togglegroup
bind = SUPER, Tab, changegroupactive

# Sous-maps pour bindings imbriqués
bind = SUPER, R, submap, resize
submap = resize
bind = , right, resizeactive, 10 0
bind = , escape, submap, reset
submap = reset
```

---

## Retour en arrière vers i3

Si vous souhaitez revenir à i3 :

```bash
# Depuis GNOME ou TTY (Ctrl+Alt+F2)
cd /opt/skillarch

# Désinstaller Hyprland
sudo pacman -Rns hyprland hyprlock hypridle hyprpaper hyprpolkitagent \
    waybar grim slurp wl-clipboard clipse wlogout dunst \
    qt5-wayland qt6-wayland xdg-desktop-portal-hyprland

# Réinstaller i3
mkdir -p ~/.config/skillarch && echo "i3" > ~/.config/skillarch/wm-choice
make install-gui

# Redémarrer
sudo reboot

# Au login, sélectionner "i3"
```

---

## Ressources supplémentaires

### Documentation officielle
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Hyprland GitHub](https://github.com/hyprwm/Hyprland)
- [SkillArch Discord](https://discord.com/invite/tH8wEpNKWS)

### Guides Hyprland SkillArch
- `config/hypr/CONFIGURATION.md` - Guide de configuration détaillé
- `config/hypr/HYPR_ECOSYSTEM_GUIDE.md` - Écosystème Hyprland complet
- `WM_COMPARISON.md` - Comparaison détaillée i3 vs Hyprland

### Commandes utiles
```bash
# Infos WM actif
ska-wm-info

# Bindings du WM actif
ska-help-bindings

# Rechercher dans les aliases
ska-help-aliases

# Aide Hyprland
man hyprland
hyprctl --help
```

---

## Checklist de migration

- [ ] Sauvegarde config i3/polybar actuelle
- [ ] Désinstallation packages i3 (si installation propre)
- [ ] Installation Hyprland via `make install-gui`
- [ ] Redémarrage et sélection session Hyprland
- [ ] Test des bindings de base
- [ ] Configuration multi-monitor (si applicable)
- [ ] Personnalisation waybar/dunst
- [ ] Test applications critiques
- [ ] Configuration lockscreen (hyprlock)
- [ ] Configuration idle (hypridle)
- [ ] Wallpaper personnalisé
- [ ] Suppression ancienne config i3 (optionnel)

---

**Dernière mise à jour** : 2025-10-21
**Version SkillArch** : 2.0.0 (feature/wm-choice)
**Auteur** : Claude Code
