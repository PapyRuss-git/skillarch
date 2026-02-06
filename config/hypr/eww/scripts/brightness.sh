#!/bin/bash
# brightness.sh - Real-time brightness listener for eww deflisten

get_brightness() {
    percent=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo "")

    if [ -z "$percent" ]; then
        icon="󰃠"
        percent="0"
    elif [ "$percent" -le 30 ]; then
        icon="󰃞"
    elif [ "$percent" -le 70 ]; then
        icon="󰃟"
    else
        icon="󰃠"
    fi

    nightlight=""
    if pgrep -x hyprsunset > /dev/null; then
        nightlight="󰌵"
    fi

    echo "{\"percent\":$percent,\"icon\":\"$icon\",\"nightlight\":\"$nightlight\"}"
}

# Initial output
get_brightness

# Watch backlight sysfs for changes
backlight_dir=$(ls -d /sys/class/backlight/*/ 2>/dev/null | head -1)
if [ -n "$backlight_dir" ] && command -v inotifywait &>/dev/null; then
    inotifywait -m -e modify "${backlight_dir}brightness" 2>/dev/null | while read -r _; do
        get_brightness
    done
else
    # Fallback: fast poll
    while sleep 0.5; do
        get_brightness
    done
fi
