#!/bin/bash

# Script to dynamically manage waybar window module visibility
# Monitors Hyprland window changes and restarts waybar with appropriate config

CONFIG_DIR="/opt/skillarch/config/waybar"
CONFIG_BASE="$CONFIG_DIR/config.jsonc"
CONFIG_NO_WINDOW="$CONFIG_DIR/config-no-window.jsonc"

generate_no_window_config() {
    # Create config without window module
    sed 's/"modules-left": \["hyprland\/workspaces", "hyprland\/window"\]/"modules-left": ["hyprland\/workspaces"]/' "$CONFIG_BASE" > "$CONFIG_NO_WINDOW"
}

check_active_window() {
    hyprctl activewindow -j | jq -r '.title' 2>/dev/null
}

current_config=""

# Generate the no-window config
generate_no_window_config

# Monitor window changes
socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r event; do
    if [[ $event == *"activewindow"* ]] || [[ $event == *"closewindow"* ]] || [[ $event == *"openwindow"* ]]; then
        sleep 0.1 # Small delay to ensure window state is updated
        
        active_window=$(check_active_window)
        
        if [[ -z "$active_window" || "$active_window" == "null" ]]; then
            # No active window - use config without window module
            if [[ "$current_config" != "no-window" ]]; then
                current_config="no-window"
                pkill waybar
                waybar -c "$CONFIG_NO_WINDOW" &
            fi
        else
            # Active window exists - use full config
            if [[ "$current_config" != "with-window" ]]; then
                current_config="with-window"
                pkill waybar
                waybar -c "$CONFIG_BASE" &
            fi
        fi
    fi
done