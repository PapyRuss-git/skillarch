#!/bin/bash

# SkillArch Display Toggle Script for Waybar
# Toggles display layout when screens are detected in wrong order

# Get current display configuration
get_displays() {
    hyprctl monitors -j | jq -r '.[] | "\(.id):\(.name):\(.width)x\(.height)"' | sort
}

# Check if we're in Hyprland
if ! command -v hyprctl &> /dev/null; then
    echo "🖥️"
    exit 1
fi

# Get current monitors
MONITORS=$(hyprctl monitors -j)
MONITOR_COUNT=$(echo "$MONITORS" | jq length)

# Check if we have external monitors (exclude laptop built-in screen)
EXTERNAL_COUNT=$(echo "$MONITORS" | jq '[.[] | select(.name | test("^(DP|HDMI|DVI)") )] | length')

if [ "$EXTERNAL_COUNT" -ge 2 ]; then
    # Multiple external monitors - show toggle icon
    echo "🔄"
else
    # Only laptop screen, one external, or no external monitors
    echo "🖥️"
fi