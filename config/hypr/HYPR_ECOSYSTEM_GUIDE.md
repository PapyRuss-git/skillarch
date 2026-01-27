# Guide de l'Écosystème Hyprland - SkillArch

## 🎯 Vue d'ensemble

Configuration complète de l'écosystème Hyprland avec le thème Everforest pour SkillArch.

## 📦 Composants installés

### 1. **hyprland** - Compositeur Wayland
Gestionnaire de fenêtres principal avec configuration multi-moniteurs.

**Fichier** : `config/hypr/hyprland.conf`

**Fonctionnalités clés** :
- Layout AZERTY français
- 3 moniteurs configurés (eDP-1, DVI-I-1, DVI-I-2)
- Thème Everforest (bordures vertes)
- Animations et blur

### 2. **hypridle** - Gestion de l'inactivité
Daemon qui gère les actions automatiques lors de l'inactivité.

**Fichier** : `config/hypr/hypridle.conf`

**Timeline par défaut** :
- **5 min** : Diminution luminosité à 10%
- **10 min** : Verrouillage de session
- **15 min** : Extinction écrans (DPMS off)
- **30 min** : Suspension système (désactivé, décommenter si besoin)

**Commandes utiles** :
```bash
# Redémarrer hypridle
killall hypridle && hypridle &

# Vérifier le statut
pgrep -a hypridle
```

### 3. **hyprlock** - Écran de verrouillage
Interface de verrouillage élégante avec thème Everforest.

**Fichier** : `config/hypr/hyprlock.conf`

**Éléments affichés** :
- Horloge (format 24h)
- Date en français
- Nom d'utilisateur
- Niveau de batterie
- Champ de saisie avec feedback visuel

**Couleurs Everforest** :
- Texte principal : `#D3C6AA`
- Aqua (username) : `#83C092`
- Yellow (batterie) : `#DBBC7F`
- Erreur : `#E67E80` (rouge)
- Succès : `#83C092` (aqua)

**Raccourci** : `Super + L`

### 4. **hyprpaper** - Fond d'écran
Gestionnaire de wallpapers pour Wayland.

**Fichier** : `config/hypr/hyprpaper.conf`

**Configuration multi-moniteurs** :
- eDP-1 (laptop) : everforest-bg.jpg
- DVI-I-1 (IIYAMA) : everforest-bg.jpg
- DVI-I-2 (DELL vertical) : everforest-bg.jpg

**Changer le wallpaper** :
```bash
# Via IPC (sans redémarrage)
hyprctl hyprpaper preload /chemin/vers/image.jpg
hyprctl hyprpaper wallpaper "eDP-1,/chemin/vers/image.jpg"
```

### 5. **hyprsunset** - Filtre lumière bleue
Ajuste la température de couleur pour réduire la fatigue oculaire.

**Raccourci** : `Super + F9` (toggle on/off)

**Température par défaut** : 4500K

**Utilisation manuelle** :
```bash
# Activer avec température personnalisée
hyprsunset -t 3000

# Désactiver
pkill hyprsunset
```

### 6. **hyprcursor** - Curseurs personnalisés
Système de curseurs moderne pour Hyprland.

**Thème** : Bibata-Modern-Classic (24px)

**Installer d'autres thèmes** :
```bash
# Voir les thèmes disponibles
yay -Ss cursor

# Changer le thème dans hyprland.conf
env = HYPRCURSOR_THEME,nom-du-theme
```

### 7. **hyprpolkitagent** - Agent d'authentification
Gère les demandes d'élévation de privilèges.

**Auto-démarré** dans hyprland.conf

### 8. **waybar** - Barre de statut
Barre d'état personnalisable.

**Fichiers** :
- `config/waybar/config.jsonc`
- `config/waybar/style.css`

### 9. **dunst** - Notifications
Gestionnaire de notifications.

**Fichier** : `~/.config/dunst/dunstrc`

### 10. **clipse** - Gestionnaire de presse-papiers
Historique du presse-papiers pour Wayland.

**Raccourci** : `Super + V`

**Utilisation** :
- Sélectionner un élément avec les flèches
- `Enter` pour coller
- `Delete` pour supprimer

## 🎨 Thème Everforest

### Palette de couleurs utilisée

**Background** :
- Dim : `#1E2326`
- Base : `#272E33`
- Surface : `#2E383C`

**Foreground** :
- Primary : `#D3C6AA`
- Secondary : `#9DA9A0`
- Dimmed : `#7A8478`

**Accents** :
- Green : `#A7C080` (bordures actives)
- Aqua : `#83C092` (username, check)
- Yellow : `#DBBC7F` (batterie)
- Red : `#E67E80` (erreurs)
- Orange : `#E69875` (CapsLock)
- Blue : `#7FBBB3` (NumLock)
- Purple : `#D699B6` (BothLock)

## 🔧 Configuration avancée

### Variables d'environnement importantes

```bash
# Desktop Portal
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_TYPE=wayland

# Qt/Wayland
QT_QPA_PLATFORM=wayland
QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# GTK/Wayland
GDK_BACKEND=wayland,x11
SDL_VIDEODRIVER=wayland

# Curseurs
HYPRCURSOR_THEME=Bibata-Modern-Classic
HYPRCURSOR_SIZE=24
```

### Raccourcis clavier essentiels

| Raccourci | Action |
|-----------|--------|
| `Super + Return` | Terminal (Kitty) |
| `Super + Space` | Rofi (applications) |
| `Super + L` | Verrouiller |
| `Super + Shift + Q` | Fermer fenêtre |
| `Super + F` | Plein écran |
| `Super + Shift + F` | Toggle floating |
| `Super + V` | Presse-papiers |
| `Super + F9` | Night light (toggle) |
| `Super + P` | Screenshot (zone) |
| `Super + Shift + P` | Screenshot (presse-papiers) |

### Gestion des moniteurs

**Liste des moniteurs** :
```bash
hyprctl monitors
```

**Changer la disposition** :
```bash
# Éditer hyprland.conf section monitor
monitor = eDP-1,1920x1200@60,0x0,1
monitor = DVI-I-1,2560x1440@60,1920x0,1
monitor = DVI-I-2,1920x1080@60,4480x0,1,transform,3
```

**Rotation** :
- 0 = Normal
- 1 = 90°
- 2 = 180°
- 3 = 270°

### Workspaces par moniteur

```bash
workspace = 1, monitor:eDP-1, default:true
workspace = 2, monitor:DVI-I-1, default:true
workspace = 3, monitor:DVI-I-2, default:true
```

## 🐛 Dépannage

### hyprlock ne démarre pas
```bash
# Vérifier le service
systemctl --user status hyprlock

# Tester manuellement
hyprlock
```

### hypridle ne fonctionne pas
```bash
# Vérifier le processus
pgrep hypridle

# Logs
journalctl --user -u hypridle -f
```

### Fond d'écran ne s'affiche pas
```bash
# Redémarrer hyprpaper
killall hyprpaper && hyprpaper &

# Vérifier les chemins
ls -la /opt/skillarch/assets/everforest-bg.jpg
```

### Screenshots ne fonctionnent pas
```bash
# Installer les dépendances
sudo pacman -S grim slurp

# Tester
grim -g "$(slurp)" ~/test.png
```

### Night light trop orange/bleu
```bash
# Ajuster la température (1000-10000K)
hyprsunset -t 5000  # Plus chaud
hyprsunset -t 4000  # Plus froid
```

## 📚 Ressources

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Hypr Ecosystem](https://wiki.hypr.land/Hypr-Ecosystem/)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [Everforest Theme](https://github.com/sainnhe/everforest)

## 🔄 Mises à jour

### Mettre à jour les composants Hypr
```bash
yay -S hyprland hypridle hyprlock hyprpaper hyprsunset hyprcursor hyprpolkitagent
```

### Recharger la configuration
```bash
# Recharger Hyprland
hyprctl reload

# Ou avec le raccourci
Super + Shift + C
```

## 💡 Tips & Astuces

### 1. Capture d'écran rapide
```bash
# Ajouter un alias dans ~/.zshrc
alias ss='grim -g "$(slurp)" ~/Images/screenshot_$(date +%Y%m%d_%H%M%S).png'
```

### 2. Changer le blur dynamiquement
```bash
hyprctl keyword decoration:blur:size 5
hyprctl keyword decoration:blur:passes 2
```

### 3. Toggle animations
```bash
hyprctl keyword animations:enabled 0  # Désactiver
hyprctl keyword animations:enabled 1  # Activer
```

### 4. Voir toutes les fenêtres actives
```bash
hyprctl clients
```

### 5. Debug mode
```bash
# Lancer Hyprland en debug
HYPRLAND_LOG_WLR=1 hyprland
```

## 🎯 Installation rapide

Si vous réinstallez ou installez sur une nouvelle machine :

```bash
# 1. Cloner la config
cd /opt/skillarch

# 2. Créer les symlinks
ln -sf /opt/skillarch/config/hypr ~/.config/hypr

# 3. Installer les packages
yay -S hyprland hypridle hyprlock hyprpaper hyprsunset hyprcursor \
       hyprpolkitagent waybar dunst rofi kitty grim slurp \
       brightnessctl clipse

# 4. Activer le portail XDG
ln -sf /opt/skillarch/config/xdg-desktop-portal ~/.config/xdg-desktop-portal

# 5. Démarrer Hyprland
Hyprland
```

---

**Note** : Ce guide est spécifique à la configuration SkillArch. Adaptez les chemins selon votre environnement.
