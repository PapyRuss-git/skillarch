#!/bin/bash
# start-bar.sh - Intelligent bar launcher for SkillArch Hyprland
# Reads bar-choice from ~/.config/skillarch/bar-choice (default: eww)
# Detects vertical monitors (transform 1 or 3) and opens a minimal bar on them
# Each monitor gets its own bar window with per-monitor workspace filtering

BAR_CHOICE=$(cat ~/.config/skillarch/bar-choice 2>/dev/null || echo "eww")

case "$BAR_CHOICE" in
    waybar)
        killall eww 2>/dev/null
        killall quickshell 2>/dev/null
        waybar &
        ;;
    quickshell)
        killall waybar 2>/dev/null
        killall eww 2>/dev/null
        quickshell &
        ;;
    eww|*)
        killall waybar 2>/dev/null
        killall quickshell 2>/dev/null
        eww daemon 2>/dev/null
        sleep 0.3
        # Open bar per monitor: minimal for vertical, full for horizontal
        hyprctl monitors -j | jq -c '.[] | {id, transform}' | while read -r mon; do
            id=$(echo "$mon" | jq '.id')
            transform=$(echo "$mon" | jq '.transform')
            if [ "$transform" = "1" ] || [ "$transform" = "3" ]; then
                eww open "bar-minimal-$id" 2>/dev/null || true
            else
                eww open "bar-$id" 2>/dev/null || true
            fi
        done
        ;;
esac
