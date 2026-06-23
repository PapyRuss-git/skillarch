#!/bin/bash
set -o pipefail
# start-bar.sh - Bar manager for SkillArch Hyprland
# Usage: start-bar.sh [start|switch|toggle|info]
#   start   - Launch bar from saved choice (default, used by autostart)
#   switch  - Switch to a specific bar: start-bar.sh switch waybar|quickshell
#   toggle  - Cycle between waybar and quickshell
#   info    - Show current bar choice

BAR_CHOICE_FILE="$HOME/.config/skillarch/bar-choice"
DEFAULT_BAR="waybar"

is_valid_bar() {
    [ "$1" = "waybar" ] || [ "$1" = "quickshell" ]
}

read_choice() {
    cat "$BAR_CHOICE_FILE" 2>/dev/null || true
}

get_choice() {
    local stored

    stored="$(read_choice)"
    if is_valid_bar "$stored"; then
        echo "$stored"
    else
        echo "$DEFAULT_BAR"
    fi
}

save_choice() {
    local choice="$1"

    if ! is_valid_bar "$choice"; then
        echo "Error: invalid bar choice '$choice'. Must be 'waybar' or 'quickshell'." >&2
        return 1
    fi

    mkdir -p "$(dirname "$BAR_CHOICE_FILE")"
    echo "$choice" > "$BAR_CHOICE_FILE"
}

stop_bar() {
    [ "${SKA_BAR_DRY_RUN:-0}" = "1" ] && return 0
    killall "$1" 2>/dev/null
}

start_bar() {
    if [ "${SKA_BAR_DRY_RUN:-0}" = "1" ]; then
        echo "Would start $1"
    else
        "$1" &
    fi
}

launch_bar() {
    local choice="$1"

    if ! is_valid_bar "$choice"; then
        echo "Error: invalid bar choice '$choice'. Must be 'waybar' or 'quickshell'." >&2
        return 1
    fi

    case "$choice" in
        quickshell)
            stop_bar waybar
            start_bar quickshell
            ;;
        waybar)
            stop_bar quickshell
            start_bar waybar
            ;;
    esac
}

show_info() {
    local stored effective

    stored="$(read_choice)"
    effective="$(get_choice)"

    if [ -n "$stored" ] && ! is_valid_bar "$stored"; then
        echo "Stored bar choice '$stored' is invalid; using $effective"
    fi

    echo "Current bar: $effective"
}

case "${1:-start}" in
    start)
        launch_bar "$(get_choice)" || exit 1
        ;;
    switch)
        if [ -z "${2:-}" ]; then
            echo "Usage: start-bar.sh switch waybar|quickshell" >&2
            exit 1
        fi
        save_choice "$2" || exit 1
        launch_bar "$2" || exit 1
        echo "Switched to $2"
        ;;
    toggle)
        current="$(get_choice)"
        if [ "$current" = "waybar" ]; then
            save_choice "quickshell" || exit 1
            launch_bar "quickshell" || exit 1
            echo "Switched to Quickshell"
        else
            save_choice "waybar" || exit 1
            launch_bar "waybar" || exit 1
            echo "Switched to Waybar"
        fi
        ;;
    info)
        show_info
        ;;
    *)
        echo "Usage: start-bar.sh [start|switch|toggle|info]" >&2
        exit 1
        ;;
esac
