#!/bin/bash
# start-bar.sh - Intelligent bar launcher for SkillArch Hyprland
# Reads bar-choice from ~/.config/skillarch/bar-choice (default: waybar)

BAR_CHOICE=$(cat ~/.config/skillarch/bar-choice 2>/dev/null || echo "waybar")

case "$BAR_CHOICE" in
    quickshell)
        killall waybar 2>/dev/null
        quickshell &
        ;;
    waybar|*)
        killall quickshell 2>/dev/null
        waybar &
        ;;
esac
