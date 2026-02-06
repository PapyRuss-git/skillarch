#!/bin/bash
# start-bar.sh - Intelligent bar launcher for SkillArch Hyprland
# Reads bar-choice from ~/.config/skillarch/bar-choice (default: eww)

BAR_CHOICE=$(cat ~/.config/skillarch/bar-choice 2>/dev/null || echo "eww")

case "$BAR_CHOICE" in
    waybar)
        killall eww 2>/dev/null
        waybar &
        ;;
    eww|*)
        killall waybar 2>/dev/null
        eww daemon 2>/dev/null
        sleep 0.3
        eww open bar
        ;;
esac
