# Screenshots TODO - SkillArch WM Choice

Liste des screenshots nécessaires pour documenter le projet et la fonctionnalité de choix i3/Hyprland.

---

## Screenshots à créer

### 1. Installation - Prompt WM Choice
**Fichier** : `assets/screenshots/install-wm-prompt.png`

**Comment** :
```bash
cd /opt/skillarch
make install
# Prendre screenshot au moment du prompt de choix WM
```

**Contenu attendu** :
```
════════════════════════════════════════════════════════
  SkillArch Window Manager Selection
════════════════════════════════════════════════════════

Choose your window manager:
  1) i3-gaps (X11)           - Stable, mature, widely supported
  2) Hyprland (Desktop)      - Modern, smooth animations, cutting-edge
  3) Hyprland (VM Mode)      - Optimized for virtual machines

Enter choice [1-3]:
```

---

### 2. i3 Desktop - Vue d'ensemble
**Fichier** : `assets/screenshots/i3-desktop-overview.png`

**Comment** :
```bash
# Depuis une session i3
# Ouvrir : kitty, rofi, firefox, burpsuite
# Arranger les fenêtres en tiling
# Prendre screenshot avec flameshot
flameshot full -p ~/Pictures/
```

**Contenu attendu** :
- Polybar en haut avec workspaces, CPU, RAM, date
- Plusieurs fenêtres en tiling (terminal, browser, tools)
- Couleurs Everforest theme
- i3 gaps visibles

---

### 3. i3 Desktop - Rofi Launcher
**Fichier** : `assets/screenshots/i3-rofi-launcher.png`

**Comment** :
```bash
# Depuis i3, appuyer sur $mod+d
# Prendre screenshot avec le rofi ouvert
flameshot full -p ~/Pictures/
```

**Contenu attendu** :
- Rofi spotlight-dark theme
- Liste d'applications
- Champ de recherche actif

---

### 4. Hyprland Desktop - Vue d'ensemble
**Fichier** : `assets/screenshots/hyprland-desktop-overview.png`

**Comment** :
```bash
# Depuis une session Hyprland
# Ouvrir : kitty, rofi, firefox, burpsuite
# Arranger les fenêtres
# Prendre screenshot
grim -g "$(slurp)" ~/Pictures/hyprland-overview.png
# Ou pour tout l'écran :
grim ~/Pictures/hyprland-overview.png
```

**Contenu attendu** :
- Waybar en haut
- Fenêtres avec animations/ombres Hyprland
- Thème Everforest
- Workspace indicators

---

### 5. Hyprland Desktop - Waybar Status Bar
**Fichier** : `assets/screenshots/hyprland-waybar-detail.png`

**Comment** :
```bash
# Screenshot de la barre waybar seulement
grim -g "0,0,1920,30" ~/Pictures/waybar.png
# Ajuster les coordonnées selon votre résolution
```

**Contenu attendu** :
- Workspaces
- Tray icons
- CPU/RAM monitoring
- Network, battery
- Clock

---

### 6. ska-wm-info - Output i3
**Fichier** : `assets/screenshots/ska-wm-info-i3.png`

**Comment** :
```bash
# Depuis i3
kitty -e bash -c "ska-wm-info; read"
# Prendre screenshot du terminal
```

**Contenu attendu** :
```
╔════════════════════════════════════════════════════════════════════╗
║              SkillArch Window Manager Information                  ║
╚════════════════════════════════════════════════════════════════════╝

DETECTION
  Window Manager: i3
  Session Type:   X11
  ...
```

---

### 7. ska-wm-info - Output Hyprland
**Fichier** : `assets/screenshots/ska-wm-info-hyprland.png`

**Comment** :
```bash
# Depuis Hyprland
kitty -e bash -c "ska-wm-info; read"
# Prendre screenshot
grim ~/Pictures/ska-wm-info-hyprland.png
```

**Contenu attendu** :
```
╔════════════════════════════════════════════════════════════════════╗
║              SkillArch Window Manager Information                  ║
╚════════════════════════════════════════════════════════════════════╝

DETECTION
  Window Manager: Hyprland
  Session Type:   Wayland
  ...
```

---

### 8. ska-help-bindings - i3
**Fichier** : `assets/screenshots/ska-help-bindings-i3.png`

**Comment** :
```bash
# Depuis i3
ska-help-bindings
# Laisser le fzf ouvert
# Screenshot
```

**Contenu attendu** :
- Interface fzf
- Liste des bindings i3
- Recherche active

---

### 9. ska-help-bindings - Hyprland
**Fichier** : `assets/screenshots/ska-help-bindings-hyprland.png`

**Comment** :
```bash
# Depuis Hyprland
ska-help-bindings
# Screenshot avec grim
```

**Contenu attendu** :
- Interface fzf
- Liste des bindings Hyprland
- Format différent d'i3

---

### 10. Docker - Build process
**Fichier** : `assets/screenshots/docker-build-process.png`

**Comment** :
```bash
# Lancer le build
make docker-build-full-i3
# Screenshot pendant le build (showing WM_CHOICE detection)
```

**Contenu attendu** :
- Output terminal du build Docker
- Ligne montrant "WM_CHOICE: i3" détecté
- Installation des packages i3-specific

---

### 11. Hyprland Animations - Window Movement
**Fichier** : `assets/screenshots/hyprland-animations.gif` (GIF animé)

**Comment** :
```bash
# Enregistrer un GIF avec wf-recorder
wf-recorder -g "$(slurp)" -f ~/Pictures/hyprland-anim.mp4
# Déplacer des fenêtres, changer workspaces
# Ctrl+C pour arrêter
# Convertir en GIF
ffmpeg -i ~/Pictures/hyprland-anim.mp4 -vf "fps=10,scale=1280:-1:flags=lanczos" ~/Pictures/hyprland-anim.gif
```

**Contenu attendu** :
- Animations fluides de fenêtres
- Transitions entre workspaces
- Effets de blur/shadow

---

### 12. Side-by-side Comparison
**Fichier** : `assets/screenshots/i3-vs-hyprland-comparison.png`

**Comment** :
```bash
# Créer une image composite avec ImageMagick
convert i3-desktop-overview.png hyprland-desktop-overview.png +append comparison.png
```

**Contenu attendu** :
- i3 à gauche
- Hyprland à droite
- Même layout pour comparaison visuelle

---

## Organisation des fichiers

```
assets/
├── screenshots/
│   ├── install/
│   │   └── wm-prompt.png
│   ├── i3/
│   │   ├── desktop-overview.png
│   │   ├── rofi-launcher.png
│   │   ├── ska-wm-info.png
│   │   └── ska-help-bindings.png
│   ├── hyprland/
│   │   ├── desktop-overview.png
│   │   ├── waybar-detail.png
│   │   ├── ska-wm-info.png
│   │   ├── ska-help-bindings.png
│   │   └── animations.gif
│   ├── docker/
│   │   ├── build-i3.png
│   │   └── build-hyprland.png
│   └── comparison/
│       └── i3-vs-hyprland.png
├── logo-round-cold.png (existing)
├── logo-round-hot.png (existing)
└── everforest-bg.jpg (existing)
```

---

## Utilisation dans la documentation

### readme.md
```markdown
## Window Manager Choice

<img src='assets/screenshots/install/wm-prompt.png' width='800'>

### i3 Desktop Environment
<img src='assets/screenshots/i3/desktop-overview.png' width='800'>

### Hyprland Desktop Environment
<img src='assets/screenshots/hyprland/desktop-overview.png' width='800'>
<img src='assets/screenshots/hyprland/animations.gif' width='600'>
```

### WM_COMPARISON.md
```markdown
## Visual Comparison

<img src='assets/screenshots/comparison/i3-vs-hyprland.png' width='1200'>
```

---

## Outils nécessaires

```bash
# Pour screenshots i3
sudo pacman -S flameshot

# Pour screenshots Hyprland
sudo pacman -S grim slurp

# Pour GIF recordings
sudo pacman -S wf-recorder ffmpeg

# Pour composite images
sudo pacman -S imagemagick
```

---

## Checklist

- [ ] Install prompt WM choice
- [ ] i3 desktop overview
- [ ] i3 rofi launcher
- [ ] i3 ska-wm-info output
- [ ] i3 ska-help-bindings
- [ ] Hyprland desktop overview
- [ ] Hyprland waybar detail
- [ ] Hyprland ska-wm-info output
- [ ] Hyprland ska-help-bindings
- [ ] Hyprland animations GIF
- [ ] Docker build process
- [ ] Side-by-side comparison
- [ ] Organiser dans assets/screenshots/
- [ ] Mettre à jour readme.md avec screenshots
- [ ] Mettre à jour WM_COMPARISON.md avec screenshots

---

**Note** : Les screenshots doivent être pris avec une résolution de 1920x1080 minimum pour une bonne qualité. Utiliser le thème Everforest pour la cohérence visuelle.

**Dernière mise à jour** : 2025-10-21
