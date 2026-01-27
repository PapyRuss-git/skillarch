# 🎨 Améliorations Hyprland - Configuration SkillArch

## ✅ Améliorations apportées

### 1. **hypridle** - Gestion de l'inactivité ⏰
**Fichier** : `config/hypr/hypridle.conf`

Gestion automatique de l'inactivité avec 4 niveaux :
- ⏱️  **5 min** : Diminution luminosité → 10%
- 🔒 **10 min** : Verrouillage automatique
- 🖥️  **15 min** : Extinction écrans (DPMS)
- 😴 **30 min** : Suspension (désactivé par défaut)

**Activation** : Ajouté dans `exec-once`

---

### 2. **xdg-desktop-portal-hyprland** - Portail XDG 🌐
**Modification** : Variables d'environnement dans `hyprland.conf`

Améliorations :
- ✅ Variables `XDG_CURRENT_DESKTOP=Hyprland`
- ✅ Support Wayland complet (`GDK_BACKEND`, `SDL_VIDEODRIVER`)
- ✅ Configuration Qt/GTK optimisée

**Fonctionnalités** :
- Screenshots via portail
- Partage d'écran amélioré
- Sélection de fichiers native

---

### 3. **hyprlock** - Écran de verrouillage Everforest 🔐
**Fichier** : `config/hypr/hyprlock.conf`

**Nouveau design avec thème Everforest** :
- 🕐 Horloge grande (90px) - Couleur : `#D3C6AA`
- 📅 Date en français - Couleur : `#9DA9A0`
- 👤 Username stylisé - Couleur : `#83C092` (Aqua)
- 🔋 Indicateur batterie - Couleur : `#DBBC7F` (Yellow)
- 🎨 Champ de saisie avec feedback visuel

**Indicateurs visuels** :
- ✅ Succès : Aqua (`#83C092`)
- ❌ Erreur : Rouge (`#E67E80`)
- 🔤 CapsLock : Orange (`#E69875`)
- 🔢 NumLock : Bleu (`#7FBBB3`)

**Raccourci** : `Super + L`

---

### 4. **hyprsunset** - Filtre lumière bleue 🌙
**Modification** : Raccourci dans `hyprland.conf`

**Raccourci** : `Super + F9` (toggle on/off)

**Configuration** :
- Température par défaut : **4500K**
- Réduit la fatigue oculaire
- Activation/désactivation instantanée

**Utilisation manuelle** :
```bash
# Activer
hyprsunset -t 4500

# Désactiver
pkill hyprsunset
```

---

### 5. **hyprpaper** - Fond d'écran multi-moniteurs 🖼️
**Fichier** : `config/hypr/hyprpaper.conf`

**Améliorations** :
- ✅ Configuration par moniteur (eDP-1, DVI-I-1, DVI-I-2)
- ✅ Préchargement pour performance
- ✅ IPC activé pour contrôle en temps réel
- ✅ Fallback automatique

**Changer le wallpaper** :
```bash
hyprctl hyprpaper preload /chemin/image.jpg
hyprctl hyprpaper wallpaper "eDP-1,/chemin/image.jpg"
```

---

### 6. **hyprcursor** - Curseurs personnalisés 🖱️
**Modification** : Variables d'environnement dans `hyprland.conf`

**Configuration** :
- Thème : **Bibata-Modern-Classic**
- Taille : **24px**
- Support hyprcursor natif activé

**Changer le thème** :
```bash
# Dans hyprland.conf
env = HYPRCURSOR_THEME,nom-du-theme
```

---

### 7. **Animations optimisées** ✨
**Modification** : Section animations dans `hyprland.conf`

**Nouvelles courbes bezier** :
- `wind` : Animation générale fluide
- `winIn` : Entrée de fenêtre rebondissante
- `winOut` : Sortie de fenêtre rapide
- `linear` : Animation de bordure continue

**Animations ajoutées** :
- ✅ windowsIn/Out séparés
- ✅ fadeSwitch, fadeShadow, fadeDim
- ✅ specialWorkspace animations
- ✅ Borderangle animé en boucle

---

### 8. **Blur & Decorations améliorés** 🎨
**Modification** : Section decoration dans `hyprland.conf`

**Blur moderne** :
- Size : 5 (au lieu de 3)
- Passes : 2 (au lieu de 1)
- new_optimizations : activé
- Vibrancy : 0.2
- Noise : 0.0117

**Ombres améliorées** :
- Range : 20 (au lieu de 4)
- Couleurs différentes actif/inactif
- Offset : `0 2` pour effet de profondeur

**Dimming** :
- Fenêtres inactives légèrement atténuées (5%)

---

### 9. **Window Rules enrichies** 📐
**Modification** : Section windowrulev2 dans `hyprland.conf`

**Nouvelles règles** :
- 🔧 Outils de sécurité (Burp, Wireshark, Metasploit)
- 🎥 Picture-in-Picture (Firefox, Chrome)
- 🤫 Firefox sharing indicator (workspace silent)
- 📂 Dialogs XDG
- 📟 Terminal dropdown (kitty-dropdown)
- 🎨 Opacity pour kitty (95%), VSCode (90%)

---

### 10. **Script Helper ska-hypr** 🛠️
**Fichier** : `/opt/skillarch/scripts/ska-hypr-helper`

**Commandes disponibles** :
```bash
ska-hypr info              # Infos système
ska-hypr reload            # Recharger config
ska-hypr restart           # Redémarrer Hyprland
ska-hypr toggle-anim       # Toggle animations
ska-hypr toggle-blur       # Toggle blur
ska-hypr monitors          # Liste moniteurs
ska-hypr windows           # Liste fenêtres
ska-hypr workspaces        # Liste workspaces
ska-hypr night-light       # Toggle filtre lumière bleue
ska-hypr wallpaper         # Changer fond d'écran (fzf)
ska-hypr lock              # Verrouiller
ska-hypr idle-status       # Statut hypridle
ska-hypr performance       # Mode performance (no blur/anim)
ska-hypr beauty            # Mode beauté (blur/anim)
```

**Aliases créés** :
- `ska-hypr-info`
- `ska-hypr-reload`
- `ska-hypr-perf`
- `ska-hypr-beauty`
- `ska-hypr-nightlight`
- ... et plus !

---

## 🎯 Utilisation rapide

### Démarrage
Hyprland lance automatiquement :
- ✅ waybar (barre de statut)
- ✅ hyprpaper (fond d'écran)
- ✅ hypridle (gestion inactivité)
- ✅ hyprpolkitagent (authentification)
- ✅ dunst (notifications)
- ✅ clipse (presse-papiers)

### Raccourcis essentiels
| Raccourci | Action |
|-----------|--------|
| `Super + Return` | Terminal (Kitty) |
| `Super + Space` | Rofi (applications) |
| `Super + L` | Verrouiller |
| `Super + F9` | Night light |
| `Super + P` | Screenshot zone |
| `Super + V` | Presse-papiers |
| `Super + H` | Aide bindings |

### Modes de performance
```bash
# Mode performance (économie batterie, max FPS)
ska-hypr-perf

# Mode beauté (blur, animations)
ska-hypr-beauty
```

---

## 📊 Avant / Après

### Avant
- ❌ Pas de gestion inactivité automatique
- ❌ Écran de verrouillage basique
- ❌ Pas de filtre lumière bleue
- ❌ Blur/animations basiques
- ❌ Pas d'outils de gestion

### Après
- ✅ hypridle avec 4 niveaux d'économie
- ✅ hyprlock Everforest design
- ✅ hyprsunset intégré (Super+F9)
- ✅ Blur optimisé + animations fluides
- ✅ Script ska-hypr complet
- ✅ Window rules enrichies
- ✅ Portail XDG configuré

---

## 🔗 Ressources

- **Guide complet** : `/opt/skillarch/config/hypr/HYPR_ECOSYSTEM_GUIDE.md`
- **Config Hyprland** : `/opt/skillarch/config/hypr/hyprland.conf`
- **Config hypridle** : `/opt/skillarch/config/hypr/hypridle.conf`
- **Config hyprlock** : `/opt/skillarch/config/hypr/hyprlock.conf`
- **Script helper** : `/opt/skillarch/scripts/ska-hypr-helper`

**Documentation officielle** :
- [Hypr Ecosystem](https://wiki.hypr.land/Hypr-Ecosystem/)
- [Hyprland Wiki](https://wiki.hypr.land/)

---

## 🚀 Prochaines étapes recommandées

1. **Tester la configuration**
   ```bash
   # Recharger Hyprland
   ska-hypr-reload

   # Vérifier les composants
   ska-hypr-info
   ```

2. **Personnaliser hypridle**
   - Éditer `/opt/skillarch/config/hypr/hypridle.conf`
   - Ajuster les timeouts selon vos besoins

3. **Personnaliser hyprlock**
   - Modifier les couleurs dans `hyprlock.conf`
   - Changer le fond d'écran

4. **Explorer le helper**
   ```bash
   ska-hypr help
   ```

---

**Note** : Toutes ces améliorations sont basées sur la documentation officielle Hypr Ecosystem et optimisées pour le thème Everforest de SkillArch.

Fait avec ❤️ par Claude Code
