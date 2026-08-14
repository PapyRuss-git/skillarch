# Configuration Hyprland SkillArch - Documentation Complète

## 📋 Vue d'ensemble

Cette documentation détaille **chaque aspect** de la configuration Hyprland pour SkillArch, incluant toutes les sections, options et justifications.

**Version Hyprland** : Compatible avec Hyprland 0.55+ (config Lua)
**Thème** : Everforest Hard Dark
**Layout clavier** : AZERTY (FR)
**Multi-moniteurs** : 3 écrans configurés

> **⚠️ Migration Lua (Hyprland 0.55+)** : depuis Hyprland 0.55 (mai 2026), le format
> hyprlang `.conf` est déprécié et sera supprimé de Hyprland. La configuration
> principale est désormais `hyprland.lua` (API `hl.*`). Les overrides de mode sont
> dans `hyprland-desktop.lua` / `hyprland-vm.lua` (symlinkés en
> `~/.config/hypr/hyprland-mode.lua` par l'installeur), et les overrides moniteurs
> locaux dans `~/.config/hypr/monitors.lua`. Les extraits `conf` ci-dessous
> documentent l'ancienne syntaxe à titre de référence ; la logique et les valeurs
> sont identiques dans `hyprland.lua`. Les outils hypr* (hypridle, hyprlock,
> hyprpaper, hyprsunset) restent en hyprlang `.conf`.

---

## 📁 Structure des fichiers

```
/opt/skillarch/config/hypr/
├── hyprland.lua            # Configuration principale (Lua, Hyprland 0.55+)
├── hyprland-desktop.lua    # Overrides mode desktop (vide, defaults desktop)
├── hyprland-vm.lua         # Overrides mode VM (pas d'animations/blur/ombres)
├── hypridle.conf           # Gestion de l'inactivité
├── hyprlock.conf           # Écran de verrouillage
├── hyprpaper.conf          # Fond d'écran
├── CONFIGURATION.md        # Ce fichier (documentation)
├── HYPR_ECOSYSTEM_GUIDE.md # Guide de l'écosystème
└── IMPROVEMENTS.md         # Résumé des améliorations
```

---

## 🔧 hyprland.lua - Configuration principale

### Section 1 : Variables d'environnement

#### Variables Desktop Portal
```conf
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
```
**Pourquoi** : Identifie correctement l'environnement Hyprland pour les applications et le portail XDG.

#### Variables Qt/Wayland
```conf
env = QT_QPA_PLATFORM,wayland
env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
```
**Pourquoi** :
- Force Qt à utiliser Wayland au lieu de XWayland
- `qt6ct` permet la personnalisation du thème Qt
- Désactive les décorations de fenêtre Qt (gérées par Hyprland)

#### Variables GTK/SDL
```conf
env = GDK_BACKEND,wayland,x11
env = SDL_VIDEODRIVER,wayland
```
**Pourquoi** :
- GTK préfère Wayland, fallback sur X11 si nécessaire
- SDL utilise Wayland pour les jeux

#### Variables Curseur
```conf
env = HYPRCURSOR_THEME,Bibata-Modern-Classic
env = HYPRCURSOR_SIZE,24
```
**Pourquoi** : Configure le thème de curseur Hyprland natif (meilleure performance que Xcursor).

---

### Section 2 : Configuration des moniteurs

```conf
monitor = eDP-1,1920x1200@60.00300,0x0,1
monitor = DVI-I-1,2560x1440@59.96100,1920x0,1
monitor = DVI-I-2,1920x1080@60.00000,4480x0,1,transform,3
```

**Format** : `monitor = NAME,RESxRES@HZ,POSITIONxPOSITION,SCALE,transform,ROTATION`

**Disposition** :
```
┌──────────┐  ┌────────────────┐  ┌─────┐
│  eDP-1   │  │    DVI-I-1     │  │ D │
│ (laptop) │  │   (IIYAMA)     │  │ V │
│ 1920x1200│  │  2560x1440     │  │ I │
│  @60Hz   │  │    @60Hz       │  │ - │
│  (0,0)   │  │   (1920,0)     │  │ I │
└──────────┘  └────────────────┘  │ - │
                                  │ 2 │
                                  │   │
                                  │ 1 │
                                  │ 0 │
                                  │ 8 │
                                  │ 0 │
                                  └───┘
                                (4480,0)
                                transform,3
```

**Transform** :
- `transform,3` = rotation 270° (vertical)

**Commandes utiles** :
```bash
# Lister les moniteurs disponibles
hyprctl monitors

# Changer la position d'un moniteur à la volée
hyprctl keyword monitor eDP-1,1920x1200@60,0x0,1
```

---

### Section 3 : Workspaces par moniteur

```conf
workspace = 1, monitor:eDP-1, default:true
workspace = 2, monitor:DVI-I-1, default:true
workspace = 3, monitor:DVI-I-2, default:true
```

**Pourquoi** : Chaque moniteur a son workspace par défaut. Les workspaces 4-10 sont libres et peuvent être assignés dynamiquement.

**Comportement** :
- Workspace 1 → toujours sur eDP-1 (laptop)
- Workspace 2 → toujours sur DVI-I-1 (centre)
- Workspace 3 → toujours sur DVI-I-2 (vertical)

---

### Section 4 : Configuration input

```conf
input {
    kb_layout = fr
    kb_variant = azerty
    follow_mouse = 1
    natural_scroll = false

    touchpad {
        natural_scroll = false
        tap-to-click = true
        drag_lock = true
        disable_while_typing = true
    }

    sensitivity = 0
}
```

**Options clavier** :
- `kb_layout = fr` : Layout français
- `kb_variant = azerty` : Variante AZERTY

**Options souris** :
- `follow_mouse = 1` : Focus suit le curseur
- `natural_scroll = false` : Scroll classique (non inversé)

**Options touchpad** :
- `tap-to-click = true` : Clic au toucher
- `drag_lock = true` : Maintien du drag après relâchement
- `disable_while_typing = true` : Désactive pendant la frappe

**Sensitivity** : `0` = sensibilité par défaut (pas d'accélération)

---

### Section 5 : General settings

```conf
general {
    gaps_in = 5
    gaps_out = 5
    border_size = 2
    col.active_border = rgba(a7c080ff) rgba(83c092ff) 45deg
    col.inactive_border = rgba(5c6a72aa)
    layout = dwindle
    allow_tearing = false
}
```

**Gaps** :
- `gaps_in = 5` : Espacement entre fenêtres (5px)
- `gaps_out = 5` : Espacement fenêtres/bords écran (5px)

**Bordures** :
- `border_size = 2` : Épaisseur 2px
- `col.active_border` : Gradient Everforest Green → Aqua (45°)
  - `#A7C080` (Everforest Green)
  - `#83C092` (Everforest Aqua)
- `col.inactive_border` : Gris Everforest semi-transparent (`#5C6A72AA`)

**Layout** :
- `dwindle` : Algorithme de tiling dynamique (split alterné)
- Alternative : `master` (fenêtre principale + stack)

**Tearing** :
- `allow_tearing = false` : Pas de déchirement d'écran (Vsync forcé)

---

### Section 6 : Decoration

```conf
decoration {
    rounding = 8

    blur {
        enabled = true
        size = 5
        passes = 2
        new_optimizations = true
        xray = false
        ignore_opacity = false
        vibrancy = 0.2
        vibrancy_darkness = 0.5
        noise = 0.0117
        contrast = 0.8916
        brightness = 0.8172
    }

    shadow {
        enabled = true
        range = 20
        render_power = 3
        color = rgba(1e232680)
        color_inactive = rgba(1e232640)
        offset = 0 2
        scale = 1.0
    }

    dim_inactive = false
    dim_strength = 0.05
}
```

#### Rounding
- `rounding = 8` : Coins arrondis 8px

#### Blur (configuration optimisée)
- `size = 5` : Rayon du blur
- `passes = 2` : Nombre de passes (qualité vs performance)
- `new_optimizations = true` : Optimisations modernes (recommandé)
- `xray = false` : Pas de transparence xray
- `vibrancy = 0.2` : Intensité de vibration des couleurs
- `vibrancy_darkness = 0.5` : Assombrir zones vibrantes
- `noise = 0.0117` : Grain subtil (évite le banding)
- `contrast = 0.8916` : Contraste du blur
- `brightness = 0.8172` : Luminosité du blur

**Performance** : Si lag, réduire `passes` à 1 ou `size` à 3

#### Shadow
- `range = 20` : Taille de l'ombre
- `render_power = 3` : Intensité
- `color` : Couleur Everforest dim semi-transparent
- `color_inactive` : Ombre plus transparente pour fenêtres inactives
- `offset = 0 2` : Décalage (0px horizontal, 2px vers le bas)

#### Dimming
- `dim_inactive = false` : Désactivé par défaut
- `dim_strength = 0.05` : Force si activé (5%)

---

### Section 7 : Animations

```conf
animations {
    enabled = true

    # Courbes bezier personnalisées
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1
    bezier = linear, 0.0, 0.0, 1.0, 1.0

    # Animations fenêtres
    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 6, winIn, slide
    animation = windowsOut, 1, 5, winOut, slide
    animation = windowsMove, 1, 5, wind, slide

    # Animations bordures
    animation = border, 1, 10, default
    animation = borderangle, 1, 100, linear, loop

    # Animations fade
    animation = fade, 1, 5, default

    # Animations workspaces
    animation = workspaces, 1, 6, wind, slidevert
    animation = specialWorkspace, 1, 6, wind, slidevert
}
```

#### Courbes Bezier
**Format** : `bezier = NOM, x1, y1, x2, y2`

- `wind` : Courbe élastique douce (effet rebond léger)
- `winIn` : Entrée rebondissante
- `winOut` : Sortie rapide avec légère accélération
- `liner` / `linear` : Linéaire (pour bordures)

#### Animations format
**Format** : `animation = TYPE, ENABLED, SPEED, CURVE, STYLE`

**Types d'animations** :
- `windows` : Fenêtre générale
- `windowsIn` : Ouverture fenêtre
- `windowsOut` : Fermeture fenêtre
- `windowsMove` : Déplacement fenêtre
- `border` : Changement couleur bordure
- `borderangle` : Rotation gradient bordure (effet animé)
- `fade` : Fondu
- `workspaces` : Changement workspace
- `specialWorkspace` : Workspace spécial (scratchpad)

**Vitesse** :
- Plus le chiffre est haut, plus c'est lent
- `1` = très rapide (quasi instantané), `10` = très lent
- **Valeurs actuelles : 1-2 (ultra rapides)**
- Valeurs recommandées : 3-5 (équilibrées) ou 6-8 (lentes)

**Styles** :
- `slide` : Glissement
- `slidevert` : Glissement vertical
- `popin` : Apparition depuis le centre

---

### Section 8 : Layouts

#### Dwindle (layout principal)
```conf
dwindle {
    pseudotile = true
    preserve_split = true
}
```

**Options** :
- `pseudotile = true` : Fenêtres flottantes conservent leur ratio
- `preserve_split = true` : Conserve la direction du split

**Comportement** :
- Split automatique horizontal/vertical alterné
- Super + clic droit = resize
- Super + clic gauche = move

#### Master (layout alternatif)
```conf
master {
    new_status = master
}
```

**Options** :
- `new_status = master` : Nouvelle fenêtre devient master
- Alternative : `new_status = slave` (devient slave)

**Basculer layout** : Ajouter un binding si nécessaire

---

### Section 9 : Gestures (trackpad)

```conf
gestures {
    gesture = 3, horizontal, workspace
    gesture = 4, up, float
}
```

**Format** : `gesture = FINGERS, DIRECTION, ACTION`

**Configured** :
- 3 doigts horizontal : Changement workspace
- 4 doigts haut : Toggle floating

**Autres directions** :
- `up`, `down`, `left`, `right`
- `horizontal`, `vertical`

**Autres actions** :
- `workspace` : Change workspace
- `float` : Toggle floating
- `fullscreen` : Toggle fullscreen

---

### Section 10 : Misc

```conf
misc {
    force_default_wallpaper = -1
    disable_hyprland_logo = false
}
```

**Options** :
- `force_default_wallpaper = -1` : Pas de wallpaper par défaut Hyprland
- `disable_hyprland_logo = false` : Logo Hyprland au démarrage (désactiver avec `true`)

**Autres options utiles (non utilisées)** :
```conf
# Désactiver contrôle VRR
# vrr = 0

# Désactiver focus sur survol
# mouse_move_enables_dpms = true

# Désactiver Hyprland pendant jeux
# no_direct_scanout = false
```

---

### Section 11 : Window Rules

#### Format général
```conf
windowrulev2 = RULE,CRITERIA
```

#### Règles GNOME apps
```conf
windowrulev2 = float,class:^(gnome-control-center)$
windowrulev2 = float,class:^(org.gnome.Nautilus)$,title:^(.*Properties)$
windowrulev2 = float,class:^(pavucontrol)$
```

**Pourquoi** : Applications système GNOME s'affichent mieux en mode floating.

#### Clipboard manager (clipse)
```conf
windowrulev2 = float,class:^(floating)$
windowrulev2 = center,class:^(floating)$
windowrulev2 = size 800 600,class:^(floating)$
```

**Pourquoi** : Clipse lancé avec `--class=floating` → fenêtre centrée 800x600.

#### Security tools
```conf
windowrulev2 = float,class:^(burpsuite-).*$
windowrulev2 = float,title:^(Wireshark)$
windowrulev2 = float,title:^(Metasploit)$
```

**Pourquoi** : Outils de pentest fonctionnent mieux en floating (fenêtres multiples).

#### Picture-in-Picture
```conf
windowrulev2 = float,title:^(Picture-in-Picture)$
windowrulev2 = pin,title:^(Picture-in-Picture)$
windowrulev2 = size 640 360,title:^(Picture-in-Picture)$
windowrulev2 = move 100%-w-20 100%-w-20,title:^(Picture-in-Picture)$
```

**Pourquoi** :
- `float` : Mode floating
- `pin` : Reste visible sur tous workspaces
- `size 640 360` : Taille 16:9
- `move 100%-w-20 100%-w-20` : Coin bas-droit avec marge

#### Firefox sharing indicator
```conf
windowrulev2 = workspace special:silent,title:^(Firefox — Sharing Indicator)$
windowrulev2 = workspace special:silent,title:^(.*is sharing (your screen|a window)\.)$
```

**Pourquoi** : Cache l'indicateur de partage dans un workspace spécial.

#### XDG dialogs
```conf
windowrulev2 = float,class:^(xdg-desktop-portal-gtk)$
windowrulev2 = size 800 600,class:^(xdg-desktop-portal-gtk)$
windowrulev2 = center,class:^(xdg-desktop-portal-gtk)$
```

**Pourquoi** : Dialogs système (sélection fichiers, etc.) centrés et floating.

#### Terminal dropdown
```conf
windowrulev2 = float,class:^(kitty-dropdown)$
windowrulev2 = size 80% 60%,class:^(kitty-dropdown)$
windowrulev2 = move 10% 5%,class:^(kitty-dropdown)$
```

**Utilisation** :
```bash
kitty --class=kitty-dropdown
```

**Pourquoi** : Terminal dropdown style Quake/Guake.

#### Opacity rules
```conf
windowrulev2 = opacity 0.95 0.85,class:^(kitty)$
windowrulev2 = opacity 0.90 0.80,class:^(code-url-handler)$
windowrulev2 = opacity 1.0 override,class:^(zen-alpha)$
```

**Format** : `opacity FOCUS UNFOCUS`

**Pourquoi** :
- Kitty : 95% focus, 85% unfocus (transparence légère)
- VSCode : 90% focus, 80% unfocus
- Zen Browser : 100% opaque (override force l'opacité)

---

### Section 12 : Autostart

```conf
exec-once = waybar
exec-once = hyprpaper
exec-once = hypridle
exec-once = hyprpolkitagent
exec-once = dunst
exec-once = clipse -listen
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = /usr/lib/gsd-rfkill
```

**Composants démarrés** :
1. `waybar` : Barre de statut
2. `hyprpaper` : Gestionnaire fond d'écran
3. `hypridle` : Gestion inactivité
4. `hyprpolkitagent` : Agent authentification Polkit
5. `dunst` : Notifications
6. `clipse -listen` : Clipboard manager (daemon)
7. `polkit-gnome-authentication-agent-1` : Agent Polkit GNOME (fallback)
8. `gsd-rfkill` : Gestion WiFi/Bluetooth GNOME

**exec-once vs exec** :
- `exec-once` : Exécuté une seule fois au démarrage
- `exec` : Exécuté à chaque rechargement config

---

### Section 13 : Keybindings

#### Format
```conf
bind = MODIFIERS, KEY, ACTION, PARAMS
bindm = MODIFIERS, MOUSE, ACTION
```

**Modifiers** :
- `$mainMod` = `SUPER` (touche Windows)
- `SHIFT`, `CTRL`, `ALT`

#### Terminal et apps
```conf
bind = $mainMod, Return, exec, kitty
bind = $mainMod SHIFT, Return, exec, zen-browser
bind = $mainMod SHIFT, Q, killactive,
bind = $mainMod, Space, exec, rofi -show drun
bind = $mainMod SHIFT, Space, exec, rofi -show run
bind = $mainMod CTRL, Space, exec, rofi -show window
```

**Raccourcis** :
- `Super + Enter` : Terminal (Kitty)
- `Super + Shift + Enter` : Navigateur (Zen)
- `Super + Shift + Q` : Fermer fenêtre active
- `Super + Space` : Launcher applications
- `Super + Shift + Space` : Launcher commandes
- `Super + Ctrl + Space` : Sélecteur fenêtres

#### Window management
```conf
bind = $mainMod, Left, movefocus, l
bind = $mainMod, Right, movefocus, r
bind = $mainMod, Up, movefocus, u
bind = $mainMod, Down, movefocus, d

bind = $mainMod SHIFT, Left, movewindow, l
bind = $mainMod SHIFT, Right, movewindow, r
bind = $mainMod SHIFT, Up, movewindow, u
bind = $mainMod SHIFT, Down, movewindow, d

bind = $mainMod, F, fullscreen,
bind = $mainMod SHIFT, F, togglefloating,
```

**Raccourcis** :
- `Super + Flèches` : Changer focus
- `Super + Shift + Flèches` : Déplacer fenêtre
- `Super + F` : Plein écran
- `Super + Shift + F` : Toggle floating

#### Workspaces AZERTY
```conf
bind = $mainMod, ampersand, workspace, 1      # &
bind = $mainMod, eacute, workspace, 2         # é
bind = $mainMod, quotedbl, workspace, 3       # "
bind = $mainMod, apostrophe, workspace, 4     # '
bind = $mainMod, parenleft, workspace, 5      # (
bind = $mainMod, minus, workspace, 6          # -
bind = $mainMod, egrave, workspace, 7         # è
bind = $mainMod, underscore, workspace, 8     # _
bind = $mainMod, ccedilla, workspace, 9       # ç
bind = $mainMod, agrave, workspace, 10        # à
```

**Pourquoi** : Adaptation AZERTY (touches numériques en Shift).

#### Move to workspace AZERTY
```conf
bind = $mainMod SHIFT, ampersand, movetoworkspace, 1
bind = $mainMod SHIFT, eacute, movetoworkspace, 2
# ... etc
```

**Raccourcis** :
- `Super + &` : Workspace 1
- `Super + Shift + &` : Déplacer vers workspace 1

#### Screenshots
```conf
bind = $mainMod, P, exec, grim -g "$(slurp)" ~/Images/screenshot_$(date +%Y%m%d_%H%M%S).png
bind = $mainMod SHIFT, P, exec, grim -g "$(slurp)" - | wl-copy
```

**Outils** :
- `grim` : Capture d'écran Wayland
- `slurp` : Sélection de zone

**Raccourcis** :
- `Super + P` : Screenshot zone → fichier
- `Super + Shift + P` : Screenshot zone → clipboard

#### Audio controls
```conf
bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
bind = , XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle
bind = $mainMod, M, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle
```

**Touches média** : Volume +/-, Mute, Mic Mute
**Raccourci clavier** : `Super + M` = Mute micro

#### Brightness
```conf
bind = , XF86MonBrightnessUp, exec, brightnessctl set +5%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
```

**Touches Fn** : Brightness +/-

#### Night light (hyprsunset)
```conf
bind = $mainMod, F9, exec, pkill hyprsunset || hyprsunset -t 4500
```

**Raccourci** : `Super + F9` = Toggle filtre lumière bleue

#### App shortcuts
```conf
bind = $mainMod, S, exec, pavucontrol
bind = $mainMod SHIFT, S, exec, XDG_CURRENT_DESKTOP=GNOME gnome-control-center
bind = $mainMod, E, exec, emote
bind = $mainMod, B, exec, XDG_CURRENT_DESKTOP=GNOME gnome-control-center bluetooth
bind = $mainMod, W, exec, XDG_CURRENT_DESKTOP=GNOME gnome-control-center wifi
bind = $mainMod, N, exec, nautilus
bind = $mainMod, V, exec, kitty --class=floating -e clipse
bind = $mainMod, C, exec, code
bind = $mainMod, K, exec, cursor
```

**Raccourcis** :
- `Super + S` : Pavucontrol (son)
- `Super + Shift + S` : Paramètres GNOME
- `Super + E` : Emote (emojis)
- `Super + B` : Bluetooth
- `Super + W` : WiFi
- `Super + N` : Nautilus (fichiers)
- `Super + V` : Clipboard manager
- `Super + C` : VSCode
- `Super + K` : Cursor

#### Lock & Power
```conf
bind = $mainMod, L, exec, hyprlock
bind = $mainMod, Escape, exec, wlogout
```

**Raccourcis** :
- `Super + L` : Verrouiller
- `Super + Escape` : Menu power (wlogout)

#### Hyprland controls
```conf
bind = $mainMod SHIFT, C, exec, hyprctl reload
bind = $mainMod SHIFT, R, exec, hyprctl dispatch exit
```

**Raccourcis** :
- `Super + Shift + C` : Recharger config
- `Super + Shift + R` : Quitter Hyprland

#### Help bindings
```conf
bind = $mainMod, H, exec, kitty --title "Help: SkillArch Bindings" zsh -ic "ska-help-bindings"
bind = $mainMod SHIFT, H, exec, kitty --title "Help: SkillArch Aliases" zsh -ic "ska-help-aliases"
bind = $mainMod CTRL, H, exec, kitty --title "Help: SkillArch packages" zsh -ic "ska-help-packages"
```

**Raccourcis** :
- `Super + H` : Aide raccourcis
- `Super + Shift + H` : Aide aliases
- `Super + Ctrl + H` : Aide packages

#### Mouse bindings
```conf
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
```

**Utilisation** :
- `Super + Clic gauche + Drag` : Déplacer fenêtre
- `Super + Clic droit + Drag` : Redimensionner fenêtre

#### Scratchpad
```conf
bind = $mainMod SHIFT, A, movetoworkspace, special:scratchpad
bind = $mainMod, A, togglespecialworkspace, scratchpad
```

**Raccourcis** :
- `Super + Shift + A` : Envoyer vers scratchpad
- `Super + A` : Toggle scratchpad

---

## 🔧 hypridle.conf - Gestion de l'inactivité

```conf
general {
    ignore_dbus_inhibit = false
    ignore_systemd_inhibit = false
}

# Listener 1: Diminuer luminosité après 5 min
listener {
    timeout = 300
    on-timeout = brightnessctl -s set 10%
    on-resume = brightnessctl -r
}

# Listener 2: Verrouiller après 10 min
listener {
    timeout = 600
    on-timeout = loginctl lock-session
}

# Listener 3: Éteindre écrans après 15 min
listener {
    timeout = 900
    on-timeout = hyprctl dispatch dpms off
    on-resume = hyprctl dispatch dpms on
}

# Listener 4: Suspendre après 30 min (désactivé)
# listener {
#     timeout = 1800
#     on-timeout = systemctl suspend
# }
```

**Timeouts** :
- `300` = 5 minutes = 300 secondes
- `600` = 10 minutes
- `900` = 15 minutes
- `1800` = 30 minutes

**Actions** :
- `brightnessctl -s set 10%` : Sauvegarde état + baisse à 10%
- `brightnessctl -r` : Restaure état sauvegardé
- `loginctl lock-session` : Verrouille session (appelle hyprlock)
- `hyprctl dispatch dpms off/on` : Éteint/allume écrans
- `systemctl suspend` : Suspend le système

**Inhibit** :
- `ignore_dbus_inhibit = false` : Respect inhibitions (ex: lecture vidéo)
- `ignore_systemd_inhibit = false` : Respect inhibitions systemd

---

## 🔐 hyprlock.conf - Écran de verrouillage

### General
```conf
general {
    hide_cursor = true
    grace = 3
    no_fade_in = false
    no_fade_out = false
}
```

**Options** :
- `hide_cursor = true` : Cache curseur
- `grace = 3` : 3 secondes de grâce (pas besoin de mot de passe si déverrouillage rapide)
- Fade activé pour transitions douces

### Background
```conf
background {
    monitor =
    path = /opt/skillarch/assets/everforest-bg.jpg
    blur_passes = 3
    blur_size = 8
    brightness = 0.8
    contrast = 0.9
}
```

**Options** :
- `monitor =` : Tous les moniteurs
- `blur_passes = 3` : Blur élevé
- `brightness = 0.8` : Assombri légèrement

### Labels

#### Horloge
```conf
label {
    text = cmd[update:1000] date +"%H:%M"
    color = rgba(D3C6AAFF)
    font_size = 90
    font_family = JetBrains Mono
    position = 0, 200
    halign = center
    valign = center
}
```

**Options** :
- `cmd[update:1000]` : Commande exécutée toutes les 1000ms (1s)
- Couleur Everforest foreground
- Taille 90px
- Position 200px au-dessus du centre

#### Date
```conf
label {
    text = cmd[update:60000] date +"%A, %d %B"
    color = rgba(9DA9A0FF)
    font_size = 24
    position = 0, 100
}
```

**Options** :
- Update toutes les 60s (économie CPU)
- Couleur Everforest secondary
- 100px au-dessus du centre

#### Username
```conf
label {
    text = $USER
    color = rgba(83C092FF)
    font_size = 20
    position = 0, 20
}
```

**Options** :
- Variable `$USER` automatique
- Couleur Everforest Aqua

#### Batterie
```conf
label {
    text = cmd[update:5000] bash -c 'if [ -f /sys/class/power_supply/BAT0/capacity ]; then echo "$(cat /sys/class/power_supply/BAT0/capacity)%"; else echo ""; fi'
    color = rgba(DBBC7FFF)
    position = 0, -200
}
```

**Options** :
- Check existence BAT0 (portable uniquement)
- Couleur Everforest Yellow
- Position 200px sous le centre

### Input Field
```conf
input-field {
    size = 400, 60
    position = 0, -80
    dots_center = true
    dots_size = 0.2
    dots_spacing = 0.3
    fade_on_empty = true
    fade_timeout = 1000

    font_color = rgba(D3C6AAFF)
    inner_color = rgba(2E383CFF)
    outer_color = rgba(A7C080FF)
    check_color = rgba(83C092FF)
    fail_color = rgba(E67E80FF)

    outline_thickness = 3
    placeholder_text = <span foreground="##9DA9A0"><i>Entrez votre mot de passe...</i></span>
    shadow_passes = 2
    shadow_size = 3
    shadow_color = rgba(1E2326AA)

    capslock_color = rgba(E69875FF)
    numlock_color = rgba(7FBBB3FF)
    bothlock_color = rgba(D699B6FF)
}
```

**Couleurs Everforest** :
- `font_color` : Foreground (texte saisi)
- `inner_color` : Background surface
- `outer_color` : Bordure Green
- `check_color` : Succès Aqua
- `fail_color` : Erreur Red
- `capslock_color` : Orange
- `numlock_color` : Blue
- `bothlock_color` : Purple

**Dots** :
- `dots_center = true` : Points centrés
- `dots_size = 0.2` : Taille points
- `dots_spacing = 0.3` : Espacement

**Fade** :
- `fade_on_empty = true` : Fade quand vide
- `fade_timeout = 1000` : 1 seconde

---

## 🖼️ hyprpaper.conf - Fond d'écran

```conf
# Preload wallpapers
preload = /opt/skillarch/assets/everforest-bg.jpg

# Set wallpaper per monitor
wallpaper = eDP-1,/opt/skillarch/assets/everforest-bg.jpg
wallpaper = DVI-I-1,/opt/skillarch/assets/everforest-bg.jpg
wallpaper = DVI-I-2,/opt/skillarch/assets/everforest-bg.jpg

# Fallback
wallpaper = ,/opt/skillarch/assets/everforest-bg.jpg

# Options
splash = false
ipc = on
```

**Preload** : Charge en mémoire (changement instantané)

**Wallpaper par moniteur** : Permet différents fonds par écran

**IPC** : Permet contrôle runtime :
```bash
hyprctl hyprpaper preload /path/to/image.jpg
hyprctl hyprpaper wallpaper "eDP-1,/path/to/image.jpg"
```

---

## 🎨 Palette Everforest (référence complète)

### Foreground/Text
```
Primary:   #D3C6AA (rgba(D3C6AAFF))
Secondary: #9DA9A0 (rgba(9DA9A0FF))
Dimmed:    #7A8478 (rgba(7A8478FF))
```

### Background
```
Dim:       #1E2326 (rgba(1E2326FF))
Base:      #272E33 (rgba(272E33FF))
Surface:   #2E383C (rgba(2E383CFF))
Float:     #374145 (rgba(374145FF))
Sidebar:   #414B50 (rgba(414B50FF))
Selection: #4F5B58 (rgba(4F5B58FF))
```

### Accent Colors
```
Red:    #E67E80 (rgba(E67E80FF))
Orange: #E69875 (rgba(E69875FF))
Yellow: #DBBC7F (rgba(DBBC7FFF))
Green:  #A7C080 (rgba(A7C080FF))
Blue:   #7FBBB3 (rgba(7FBBB3FF))
Aqua:   #83C092 (rgba(83C092FF))
Purple: #D699B6 (rgba(D699B6FF))
```

---

## 📊 Résumé configuration

### Composants Hypr Ecosystem
- ✅ Hyprland (compositeur)
- ✅ hypridle (inactivité)
- ✅ hyprlock (lock screen)
- ✅ hyprpaper (wallpaper)
- ✅ hyprsunset (night light)
- ✅ hyprpolkitagent (polkit)
- ✅ xdg-desktop-portal-hyprland (portail)

### Composants tiers
- ✅ waybar (status bar)
- ✅ dunst (notifications)
- ✅ rofi (launcher)
- ✅ kitty (terminal)
- ✅ clipse (clipboard)
- ✅ grim + slurp (screenshots)

### Optimisations appliquées
- ✅ Blur optimisé (new_optimizations)
- ✅ Animations fluides (courbes bezier custom)
- ✅ Window rules pour outils pentest
- ✅ Multi-moniteurs configuré
- ✅ Thème Everforest cohérent
- ✅ Opacity par application

---

## 🚀 Commandes rapides

### Informations
```bash
# Version Hyprland
hyprctl version

# Liste moniteurs
hyprctl monitors

# Liste fenêtres
hyprctl clients

# Liste workspaces
hyprctl workspaces

# Bindings actuels
hyprctl binds
```

### Configuration runtime
```bash
# Recharger config
hyprctl reload

# Changer option à la volée
hyprctl keyword decoration:blur:size 10

# Changer wallpaper
hyprctl hyprpaper wallpaper "eDP-1,/path/image.jpg"

# Toggle animations
hyprctl keyword animations:enabled 0  # off
hyprctl keyword animations:enabled 1  # on

# Toggle blur
hyprctl keyword decoration:blur:enabled 0  # off
```

### Debugging
```bash
# Logs Hyprland
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -n 1)/hyprland.log

# Logs hypridle
journalctl --user -u hypridle -f

# Test hyprlock
hyprlock
```

---

## ⚠️ Erreurs corrigées

### Erreur 1 : `misc:enable_hyprcursor`
**Problème** : Option n'existe pas dans Hyprland
**Solution** : Supprimée, curseurs gérés via `HYPRCURSOR_THEME` env var

### Erreur 2 : `misc:no_cursor_warps`
**Problème** : Option n'existe pas
**Solution** : Supprimée

### Erreur 3 : Animations invalides
**Problème** : `fadeIn`, `fadeOut`, `fadeSwitch`, etc. n'existent pas
**Solution** : Conservé uniquement `fade` qui est valide

---

## 📝 Notes importantes

1. **AZERTY** : Tous les bindings sont adaptés au clavier AZERTY français
2. **Multi-moniteurs** : Configuration pour 3 écrans, adaptez selon votre setup
3. **Thème Everforest** : Cohérent sur toute la config (hyprland + hyprlock)
4. **Performance** : Blur optimisé, désactivable avec `ska-hypr-perf`
5. **Sécurité** : Window rules spécifiques pour outils pentest

---

## 🔗 Fichiers liés

- `HYPR_ECOSYSTEM_GUIDE.md` : Guide complet écosystème
- `IMPROVEMENTS.md` : Résumé améliorations
- `/opt/skillarch/scripts/ska-hypr-helper` : Script de gestion

---

**Dernière mise à jour** : 2025-10-17
**Auteur** : SkillArch + Claude Code
**Version Hyprland** : 0.42+
