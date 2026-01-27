# Audit des Configurations - Dépendances Croisées

## Vue d'ensemble

Audit des fichiers de configuration pour identifier les dépendances X11/Wayland et les incompatibilités.

---

## Configurations Communes (compatibles i3 + Hyprland)

### ✅ Configs totalement neutres

| Fichier | Statut | Notes |
|---------|--------|-------|
| `config/kitty/kitty.conf` | ✅ Commun | Compatible X11 + Wayland (ligne 27: `wayland_titlebar_color`) |
| `config/rofi/config.rasi` | ✅ Commun | Rofi fonctionne en X11 et Wayland |
| `config/rofi/spotlight-dark.rasi` | ✅ Commun | Thème rofi |
| `config/nvim/init.lua` | ✅ Commun | Éditeur indépendant du WM |
| `config/tmux.conf` | ✅ Commun | Terminal multiplexer indépendant |
| `config/vimrc` | ✅ Commun | Éditeur indépendant |
| `config/zshrc` | ⚠️ À auditer | Voir section dédiée ci-dessous |
| `config/aliases` | ⚠️ À refactorer | Contient des aliases X11-specific |

### ⚠️ Kitty - Note importante

**Ligne 82** : `# Blur is managed at picom level, not here`
- **Problème** : Commentaire mentionne picom (X11-only)
- **Solution** :
  - Clarifier que le blur est géré par le compositor (picom pour i3, Hyprland natif)
  - Modifier en : `# Blur is managed by compositor (picom/hyprland), not here`

---

## Configurations i3 spécifiques (X11)

### Fichiers i3-only

| Fichier | Dépendances X11 | Action |
|---------|-----------------|--------|
| `config/i3/config` | i3-gaps, polybar, picom, feh, flameshot, xclip | → `config/i3/` (inchangé) |
| `config/polybar/config.ini` | polybar, X11 | → `config/polybar/` (inchangé) |
| `config/polybar/launch.sh` | polybar | → `config/polybar/` (inchangé) |
| `config/picom.conf` | picom (X11 compositor) | → `config/picom.conf` (inchangé) |
| `config/xorg.conf.d/30-touchpad.conf` | X11 | → `config/xorg.conf.d/` (inchangé) |

### Dépendances identifiées dans config/i3/config

**Commandes externes utilisées** :
- `exec_always feh --bg-scale` (ligne 26) → wallpaper X11
- `exec_always ~/.config/polybar/launch.sh` (ligne 27) → status bar X11
- `exec_always picom` (ligne 29) → compositor X11
- `exec_always i3-battery-popup` (ligne 30) → battery indicator
- `exec_always xss-lock` (ligne 36) → X11 screen locker
- `exec_always nm-applet` (ligne 40) → network manager (commun)
- `exec flameshot gui` → screenshots X11
- `exec i3lock-fancy` → lock screen X11
- `brightnessctl` → brightness control (commun ✅)
- `pavucontrol` → audio control (commun ✅)

---

## Configurations Hyprland spécifiques (Wayland)

### Fichiers Hyprland-only

| Fichier | Dépendances Wayland | Action |
|---------|---------------------|--------|
| `config/hypr/hyprland.conf` | hyprland, hyprpaper, hypridle, waybar | → `config/hypr/` (inchangé) |
| `config/hypr/hyprlock.conf` | hyprlock | → `config/hypr/` (inchangé) |
| `config/hypr/hypridle.conf` | hypridle, hyprlock | → `config/hypr/` (inchangé) |
| `config/hypr/hyprpaper.conf` | hyprpaper | → `config/hypr/` (inchangé) |
| `config/waybar/config.jsonc` | waybar | → `config/waybar/` (inchangé) |
| `config/waybar/style.css` | waybar | → `config/waybar/` (inchangé) |
| `config/waybar/scripts/*` | waybar, hyprctl | → `config/waybar/scripts/` (inchangé) |
| `config/dunst/dunstrc` | dunst (Wayland) | → `config/dunst/` (inchangé) |
| `config/clipse/config.json` | clipse (Wayland clipboard) | → `config/clipse/` (inchangé) |
| `config/clipse/custom_theme.json` | clipse | → `config/clipse/` (inchangé) |
| `config/xdg-desktop-portal/hyprland.portals` | xdg-desktop-portal-hyprland | → `config/xdg-desktop-portal/` (inchangé) |
| `config/xdg-desktop-portal/portals.conf` | portals | → `config/xdg-desktop-portal/` (inchangé) |

### Dépendances identifiées dans config/hypr/hyprland.conf

**Commandes externes utilisées** :
- `exec-once = waybar` (ligne 204) → status bar Wayland
- `exec-once = hyprpaper` (ligne 205) → wallpaper Wayland
- `exec-once = hypridle` (ligne 206) → idle manager Wayland
- `exec-once = /usr/lib/hyprpolkitagent/hyprpolkitagent` (ligne 207) → polkit agent
- `exec-once = dunst` (ligne 208) → notifications Wayland
- `exec-once = clipse -listen` (ligne 209) → clipboard Wayland
- `exec grim -g "$(slurp)"` → screenshots Wayland
- `exec hyprlock` → lock screen Wayland
- `brightnessctl` → brightness control (commun ✅)
- `pavucontrol` → audio control (commun ✅)

---

## Audit du fichier config/aliases

### ✅ Aliases déjà intelligents (détection automatique)

**Lignes 4-42** : `ska-help-bindings`
- ✅ Détecte Hyprland via `pgrep -x "Hyprland"`
- ✅ Détecte i3 via `pgrep -x "i3"`
- ✅ Fallback sur fichiers de config si WM non détecté
- **Action** : Aucune modification nécessaire

**Ligne 50** : `ska-test`
- ✅ Détecte le WM actif
- **Action** : Aucune modification nécessaire

### ⚠️ Aliases à rendre conditionnels (X11-specific)

| Ligne | Alias | Outil | Solution |
|-------|-------|-------|----------|
| 108 | `flameshotz` | flameshot | Rendre conditionnel i3-only ou créer équivalent Hyprland |
| 116 | `get-pid-click` | xprop | Rendre conditionnel i3-only |
| 136 | `cpy` | xclip | Créer alias conditionnel : xclip (i3) / wl-copy (Hyprland) |
| 137 | `paste` | xclip | Créer alias conditionnel : xclip (i3) / wl-paste (Hyprland) |
| 138 | `mcrypt-enc` | xclip | Adapter pour utiliser alias conditionnel `cpy` |

### ✅ Aliases Hyprland déjà isolés

**Lignes 239-252** : `ska-hypr-*`
- ✅ Préfixés `ska-hypr-` donc clairement Hyprland-specific
- ✅ Référencent `/opt/skillarch/scripts/ska-hypr-helper`
- **Action** : Aucune modification nécessaire

---

## Audit du fichier config/zshrc

### À vérifier

**Détection automatique du WM** :
```bash
# À ajouter dans config/zshrc (début du fichier)
# Window Manager Detection
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export SKA_WM="hyprland"
    export SKA_WM_TYPE="wayland"
elif [ -n "$I3SOCK" ]; then
    export SKA_WM="i3"
    export SKA_WM_TYPE="x11"
fi
```

**Variables d'environnement Wayland** (si Hyprland) :
- Vérifier si des variables X11 sont forcées
- Ajouter variables Wayland si `SKA_WM=hyprland`

---

## Scripts à auditer

### scripts/ska-hypr-helper

**Statut** : Existe déjà (référencé dans aliases lignes 240-252)
**Action** : Vérifier que le script existe et fonctionne

### scripts/ (nouveaux à créer)

| Script | Description | Phase |
|--------|-------------|-------|
| `ska-wm-info` | Affiche info sur WM actif | Phase 4 |
| `ska-clipboard-copy` | Wrapper cpy (xclip/wl-copy) | Phase 4 |
| `ska-clipboard-paste` | Wrapper paste (xclip/wl-paste) | Phase 4 |
| `ska-screenshot` | Wrapper screenshots (flameshot/grim) | Phase 4 |

---

## Dépendances croisées par fichier

### Résumé des problèmes

| Fichier | Problème | Sévérité | Solution |
|---------|----------|----------|----------|
| `config/aliases` | Aliases X11-specific hardcodés | 🔴 Élevée | Rendre conditionnels avec `$SKA_WM` |
| `config/kitty/kitty.conf` | Commentaire mentionne picom | 🟢 Faible | Modifier commentaire |
| `config/zshrc` | Pas de détection WM | 🟡 Moyenne | Ajouter export `SKA_WM` |
| `config/i3/config` | Appels X11 hardcodés | ✅ OK | Config i3-specific, normal |
| `config/hypr/hyprland.conf` | Appels Wayland hardcodés | ✅ OK | Config Hyprland-specific, normal |

---

## Plan d'action pour Phase 4 (Aliases et helpers)

### 4.1 Modifier config/aliases

```bash
# Remplacer lignes 108, 116, 136-138
# Détection automatique du WM (déjà présent dans ska-help-bindings)
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export SKA_WM="hyprland"
    export SKA_WM_TYPE="wayland"
elif [ -n "$I3SOCK" ]; then
    export SKA_WM="i3"
    export SKA_WM_TYPE="x11"
fi

# Aliases conditionnels
if [ "$SKA_WM" = "hyprland" ]; then
    alias cpy='wl-copy'
    alias paste='wl-paste'
    alias screenshot='grim -g "$(slurp)" ~/Images/screenshot_$(date +%Y%m%d_%H%M%S).png'
    alias screenshot-copy='grim -g "$(slurp)" - | wl-copy'
    alias lock='hyprlock'
elif [ "$SKA_WM" = "i3" ]; then
    alias cpy='xclip -selection clipboard'
    alias paste='xclip -selection clipboard -o'
    alias flameshotz='while true; do flameshot full -p ~/Downloads; sleep 1; done'
    alias get-pid-click='xprop _NET_WM_PID | cut -d" " -f3'
    alias lock='i3lock-fancy -f Bitstream-Vera-Serif -t "Welcome back to SkillArch"'
fi

# Adapter mcrypt-enc pour utiliser l'alias conditionnel
alias mcrypt-enc='f(){ PASS=$(cat /dev/urandom | base64 | head -c 20) && echo "$PASS" | cpy && tar -zcvf "$1.tar.gz" "$1" && echo "$PASS" && mcrypt "$1.tar.gz" && echo "$1.tar.gz $PASS" | cpy;  unset -f f; }; f'
```

### 4.2 Modifier config/zshrc

```bash
# Ajouter en début de fichier (après shebang si présent)
# Window Manager Detection
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    export SKA_WM="hyprland"
    export SKA_WM_TYPE="wayland"

    # Wayland environment variables
    export QT_QPA_PLATFORM=wayland
    export GDK_BACKEND=wayland
    export ELECTRON_OZONE_PLATFORM_HINT=wayland
elif [ -n "$I3SOCK" ]; then
    export SKA_WM="i3"
    export SKA_WM_TYPE="x11"
fi
```

### 4.3 Créer scripts/ska-wm-info

```bash
#!/bin/bash
# Display current window manager information

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    echo "Window Manager: Hyprland (Wayland)"
    echo "Session: $XDG_SESSION_TYPE"
    echo "Version: $(hyprctl version | head -n1)"
    echo ""
    echo "Components:"
    echo "  - Compositor: Hyprland"
    echo "  - Bar: Waybar"
    echo "  - Launcher: Rofi (Wayland mode)"
    echo "  - Screenshots: Grim + Slurp"
    echo "  - Lock: Hyprlock"
    echo "  - Clipboard: wl-clipboard + Clipse"
elif [ -n "$I3SOCK" ]; then
    echo "Window Manager: i3-gaps (X11)"
    echo "Session: $XDG_SESSION_TYPE"
    echo "Version: $(i3 --version)"
    echo ""
    echo "Components:"
    echo "  - Window Manager: i3-gaps"
    echo "  - Bar: Polybar"
    echo "  - Compositor: Picom"
    echo "  - Launcher: Rofi"
    echo "  - Screenshots: Flameshot"
    echo "  - Lock: i3lock-fancy"
    echo "  - Clipboard: xclip"
else
    echo "No known window manager detected"
    echo "Session: ${XDG_CURRENT_DESKTOP:-Unknown} (${XDG_SESSION_TYPE:-Unknown})"
fi
```

### 4.4 Modifier config/kitty/kitty.conf

```diff
- # Blur is managed at picom level, not here
+ # Blur is managed by compositor (picom for i3, Hyprland native), not here
```

---

## Validation des compatibilités

### Packages à tester (communs)

| Package | i3 (X11) | Hyprland (Wayland) | Notes |
|---------|----------|-------------------|-------|
| `kitty` | ✅ | ✅ | Support natif Wayland |
| `rofi` | ✅ | ✅ | Fonctionne en Wayland mode |
| `nautilus` | ✅ | ✅ | GNOME app, Wayland natif |
| `gnome-control-center` | ✅ | ✅ | GNOME app, Wayland natif |
| `pavucontrol` | ✅ | ✅ | PulseAudio GUI, compatible |
| `brightnessctl` | ✅ | ✅ | CLI tool, indépendant |
| `nm-connection-editor` | ✅ | ✅ | GTK app, Wayland compatible |

### Applications GUI à vérifier

| App | X11 | Wayland | Flags nécessaires |
|-----|-----|---------|-------------------|
| VSCode | ✅ | ✅ | `--enable-features=UseOzonePlatform --ozone-platform=wayland` |
| Cursor | ✅ | ✅ | Idem VSCode (Electron) |
| Chrome | ✅ | ✅ | `--enable-features=UseOzonePlatform --ozone-platform=wayland` |
| Zen Browser | ✅ | ✅ | Firefox-based, Wayland natif |

---

## Critères de validation Phase 1.3

✅ **Complété** :
- [x] Identification des configs communes
- [x] Identification des configs i3-specific
- [x] Identification des configs Hyprland-specific
- [x] Audit des aliases (lignes X11-specific identifiées)
- [x] Audit des dépendances croisées
- [x] Plan d'action pour Phase 4 défini

✅ **Dépendances croisées identifiées** :
- `config/aliases` : 5 aliases X11-specific à rendre conditionnels
- `config/kitty/kitty.conf` : 1 commentaire à clarifier
- `config/zshrc` : Ajouter détection WM

✅ **Pas de bloqueurs** :
- Aucune config ne mélange X11 et Wayland de manière problématique
- Structure actuelle permet une séparation propre
- `ska-help-bindings` déjà intelligent (bon exemple à suivre)

---

## Prochaines étapes

**Phase 2** : Refactoring Makefile
- Créer `prompt-wm-choice`
- Créer `install-gui-common`, `install-gui-i3`, `install-gui-hyprland`
- Supprimer doublons de packages
- Déplacer `xclip` de `install-cli-tools` vers `install-gui-i3`

**Phase 3** : Séparation des configs
- Structure actuelle OK, pas de réorganisation nécessaire
- Les configs sont déjà bien séparées (i3/, hypr/, etc.)
- Juste modifier les symlinks dans le Makefile

**Phase 4** : Aliases et helpers
- Implémenter détection WM dans config/zshrc
- Rendre aliases conditionnels dans config/aliases
- Créer script ska-wm-info
- Modifier commentaire kitty.conf

---

**Dernière mise à jour** : 2025-10-21
**Statut** : Phase 1.3 complétée ✅
**Prêt pour** : Phase 2 (Refactoring Makefile)
