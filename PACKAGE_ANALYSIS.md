# Analyse des Packages - Séparation i3 vs Hyprland

## État actuel du Makefile

### install-gui (lignes 105-141) - Packages i3/X11
```makefile
# Pacman packages
i3-gaps i3blocks i3lock i3lock-fancy-git i3status
dmenu
feh
rofi
nm-connection-editor
picom
polybar
kitty
brightnessctl
xorg-xhost
ttf-meslo-nerd

# AUR packages
rofi-power-menu
i3-battery-popup-git
```

### install-hyprland (lignes 203-274) - Packages Hyprland existants
```makefile
# Pacman packages
hyprland xdg-desktop-portal-hyprland
hyprpaper hyprlock hypridle hyprpicker
waybar rofi dunst
grim slurp
wl-clipboard clipse
qt5-wayland qt6-wayland
wlr-randr
brightnessctl
ttf-meslo-nerd
nautilus gnome-control-center
bluez bluez-utils gnome-settings-daemon gnome-bluetooth-3.0

# AUR packages
hyprpolkitagent
wlogout
```

### install-gui-tools (lignes 143-152) - GUI apps
```makefile
# Pacman packages
vlc-luajit
arandr cheese code code-marketplace discord dunst filezilla flameshot
ghex google-chrome gparted kompare libreoffice-fresh meld obsidian
okular qbittorrent torbrowser-launcher wireshark-qt ghidra signal-desktop
dragon-drop-git nomachine obs-studio-browser emote guvcview audacity
polkit-gnome

# AUR packages
zen-browser-bin
fswebcam
cursor-bin
```

---

## Nouvelle Architecture Proposée

### install-gui-common (Packages communs aux deux WM)

```makefile
# Terminal & fonts (les deux en ont besoin)
kitty
ttf-meslo-nerd
ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji
ttf-jetbrains-mono-nerd ttf-firacode-nerd

# Rofi (fonctionne en X11 et Wayland)
rofi

# Brightness control (commun)
brightnessctl

# GNOME apps (compatibles X11/Wayland)
nautilus
gnome-control-center
gnome-bluetooth-3.0
gnome-settings-daemon

# Bluetooth (commun)
bluez
bluez-utils

# File manager utilities
file-roller

# Audio control
pavucontrol

# Network
nm-connection-editor
```

### install-gui-i3 (X11 uniquement)

```makefile
# Pacman packages - Window Manager
i3-gaps
i3blocks
i3lock
i3lock-fancy-git
i3status

# Pacman packages - Bar
polybar

# Pacman packages - X11 compositor
picom

# Pacman packages - X11 utilities
feh                         # wallpaper
flameshot                   # screenshots
xorg-xhost                  # X11 access control
xorg-server                 # X11 server
xorg-xinit                  # X11 init
xorg-xrandr                 # display management
xclip                       # clipboard
xdotool                     # automation
dmenu                       # launcher
arandr                      # GUI display config
xss-lock                    # screen locker

# Pacman packages - Portal
xdg-desktop-portal-gtk

# Pacman packages - Polkit
polkit-gnome

# AUR packages
rofi-power-menu
i3-battery-popup-git
```

### install-gui-hyprland (Wayland uniquement)

```makefile
# Pacman packages - Compositor
hyprland
hyprlock
hypridle
hyprpaper
hyprpicker
xdg-desktop-portal-hyprland

# Pacman packages - Bar
waybar

# Pacman packages - Utilities
dunst                       # notifications
grim                        # screenshots
slurp                       # region selector
wl-clipboard                # clipboard
clipse                      # clipboard manager
wlr-randr                   # display management

# Pacman packages - Wayland support
qt5-wayland
qt6-wayland

# AUR packages
hyprpolkitagent             # polkit agent
wlogout                     # power menu
```

### install-gui-tools (Apps GUI - compatibles les deux)

**À SÉPARER :**

#### Garder dans install-gui-tools (communs)
```makefile
# Browsers & editors (supportent X11 + Wayland)
google-chrome
code
code-marketplace

# Media (supportent X11 + Wayland)
vlc-luajit
obs-studio-browser

# Office & productivity
libreoffice-fresh
obsidian

# Communication
discord
signal-desktop

# Development & analysis
ghidra
wireshark-qt
ghex

# File management
gparted
kompare
meld

# Utilities
cheese
emote
guvcview
audacity
qbittorrent
torbrowser-launcher
okular
dragon-drop-git
nomachine

# AUR
zen-browser-bin
cursor-bin
fswebcam
```

#### Déplacer vers install-gui-i3 (X11-specific)
```makefile
flameshot                   # screenshots X11 (déjà dans install-gui)
arandr                      # display config X11 (déjà dans install-gui)
```

#### Déplacer vers install-gui-hyprland (Wayland-specific)
```makefile
dunst                       # notifications (déjà dans install-hyprland)
```

#### Supprimer (doublons avec install-gui-common)
```makefile
polkit-gnome                # sera dans install-gui-i3
```

---

## Packages en doublon (à nettoyer)

| Package | Actuel i3 | Actuel Hyprland | Décision |
|---------|-----------|-----------------|----------|
| `rofi` | ✅ | ✅ | → `install-gui-common` |
| `brightnessctl` | ✅ | ✅ | → `install-gui-common` |
| `ttf-meslo-nerd` | ✅ | ✅ | → `install-gui-common` |
| `dunst` | ❌ (dans install-gui-tools) | ✅ | → `install-gui-hyprland` |
| `nm-connection-editor` | ✅ | ❌ | → `install-gui-common` |
| `nautilus` | ❌ | ✅ | → `install-gui-common` |
| `gnome-control-center` | ❌ | ✅ | → `install-gui-common` |

---

## Dépendances manquantes à ajouter

### Pour install-gui-i3
```makefile
# Pas encore installés mais nécessaires
xorg-server                 # X11 server (implicite, à ajouter)
xorg-xinit                  # X11 init
xorg-xrandr                 # display management (via arandr)
xclip                       # clipboard (actuellement dans install-cli-tools)
xdotool                     # automation
xss-lock                    # screen locker
xdg-desktop-portal-gtk      # portal
```

### Pour install-gui-hyprland
```makefile
# Tous déjà présents dans install-hyprland ✅
```

---

## Packages dans install-cli-tools à vérifier

Ligne 50 du Makefile actuel :
```makefile
xclip
```

**Décision** : `xclip` est X11-only → déplacer vers `install-gui-i3`

---

## Configurations à séparer (Phase 3)

### Configs i3 (lignes 111-141)
```
~/.config/i3/config
~/.config/polybar/config.ini
~/.config/polybar/launch.sh
~/.config/rofi/config.rasi
~/.config/picom.conf
~/.config/kitty/kitty.conf (commun)
/etc/X11/xorg.conf.d/30-touchpad.conf
```

### Configs Hyprland (lignes 228-269)
```
~/.config/hypr/hyprland.conf
~/.config/hypr/hyprpaper.conf
~/.config/hypr/hyprlock.conf
~/.config/waybar/config.jsonc
~/.config/waybar/style.css
~/.config/waybar/scripts/*
~/.config/dunst/dunstrc
~/.config/clipse/config.json
~/.config/clipse/custom_theme.json
~/.config/xdg-desktop-portal/hyprland.portals
~/.config/xdg-desktop-portal/portals.conf
~/.config/kitty/kitty.conf (commun)
```

### Configs communes
```
~/.config/kitty/kitty.conf
~/.config/rofi/config.rasi
~/.config/nvim/init.lua
~/.zshrc
~/.tmux.conf
~/.vimrc
```

---

## Résumé des packages à installer par catégorie

### Common (15 packages pacman + 0 AUR)
```
kitty ttf-meslo-nerd ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji
ttf-jetbrains-mono-nerd ttf-firacode-nerd rofi brightnessctl nautilus
gnome-control-center gnome-bluetooth-3.0 gnome-settings-daemon bluez
bluez-utils file-roller pavucontrol nm-connection-editor
```

### i3 only (19 packages pacman + 2 AUR)
```
# Pacman
i3-gaps i3blocks i3lock i3lock-fancy-git i3status polybar picom
feh flameshot xorg-xhost xorg-server xorg-xinit xorg-xrandr
xclip xdotool dmenu arandr xss-lock xdg-desktop-portal-gtk polkit-gnome

# AUR
rofi-power-menu i3-battery-popup-git
```

### Hyprland only (15 packages pacman + 2 AUR)
```
# Pacman
hyprland hyprlock hypridle hyprpaper hyprpicker xdg-desktop-portal-hyprland
waybar dunst grim slurp wl-clipboard clipse wlr-randr
qt5-wayland qt6-wayland

# AUR
hyprpolkitagent wlogout
```

### GUI tools (28 packages pacman + 3 AUR)
```
# Pacman
vlc-luajit google-chrome code code-marketplace obs-studio-browser
libreoffice-fresh obsidian discord signal-desktop ghidra wireshark-qt
ghex gparted kompare meld cheese emote guvcview audacity qbittorrent
torbrowser-launcher okular dragon-drop-git nomachine

# AUR
zen-browser-bin cursor-bin fswebcam
```

---

## Prochaines étapes

✅ **Phase 1.2 complétée** : Analyse des packages terminée

**Phase 1.3** : Auditer les configs pour dépendances croisées
- Vérifier que rofi fonctionne en Wayland
- Tester kitty dans les deux environnements
- Vérifier GNOME apps (nautilus, gnome-control-center)

**Phase 2** : Refactoring Makefile
- Créer `prompt-wm-choice`
- Créer `install-gui-common`
- Créer `install-gui-i3`
- Créer `install-gui-hyprland`
- Refactoriser `install-gui` pour appeler les bonnes cibles
- Supprimer `install-hyprland` (remplacé par logique conditionnelle)

---

**Dernière mise à jour** : 2025-10-21
**Statut** : Analyse complétée, prêt pour Phase 1.3
