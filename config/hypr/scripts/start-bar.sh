#!/bin/bash
set -o pipefail
# start-bar.sh - Bar manager for SkillArch Hyprland
# Usage: start-bar.sh [start|switch|toggle|info]
#   start   - Launch bar from saved choice (default, used by autostart)
#   switch  - Switch to a specific bar: start-bar.sh switch waybar|quickshell
#   toggle  - Cycle between waybar and quickshell
#   info    - Show current bar choice

BAR_CHOICE_FILE="$HOME/.config/skillarch/bar-choice"

get_choice() {
    cat "$BAR_CHOICE_FILE" 2>/dev/null || echo "waybar"
}

save_choice() {
    mkdir -p "$(dirname "$BAR_CHOICE_FILE")"
    echo "$1" > "$BAR_CHOICE_FILE"
}

launch_bar() {
    case "$1" in
        quickshell)
            killall waybar 2>/dev/null
            quickshell &
            ;;
        waybar|*)
            killall quickshell 2>/dev/null
            waybar &
            ;;
    esac
}

case "${1:-start}" in
    start)
        launch_bar "$(get_choice)"
        ;;
    switch)
        save_choice "${2:-waybar}"
        launch_bar "$2"
        echo "Switched to $2"
        ;;
    toggle)
        current="$(get_choice)"
        if [ "$current" = "waybar" ]; then
            save_choice "quickshell"
            launch_bar "quickshell"
            echo "Switched to Quickshell"
        else
            save_choice "waybar"
            launch_bar "waybar"
            echo "Switched to Waybar"
        fi
        ;;
    info)
        echo "Current bar: $(get_choice)"
        ;;
esac
