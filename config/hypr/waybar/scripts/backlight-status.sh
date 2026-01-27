#!/bin/bash
set -euo pipefail

# Backlight + Night light combined status for Waybar

percent=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo "")

if [[ -z "$percent" ]]; then
    icon="🔆"
    percent="N/A"
elif [[ "$percent" -le 50 ]]; then
    icon="🔅"
else
    icon="🔆"
fi

if pgrep -x hyprsunset > /dev/null; then
    nightlight="󰌵"
else
    nightlight=""
fi

if [[ -n "$nightlight" ]]; then
    echo "${icon} ${percent}% ${nightlight}"
    echo "${icon} Brightness: ${percent}% | Night light: on"
else
    echo "${icon} ${percent}%"
    echo "${icon} Brightness: ${percent}%"
fi
