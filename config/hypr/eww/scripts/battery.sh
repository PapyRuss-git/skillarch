#!/bin/bash
# battery.sh - Battery status for eww defpoll via sysfs

bat_path=""
for p in /sys/class/power_supply/BAT*; do
    [ -d "$p" ] && bat_path="$p" && break
done

if [ -z "$bat_path" ]; then
    echo "{\"percent\":100,\"status\":\"none\",\"icon\":\"󰚥\",\"class\":\"none\"}"
    exit 0
fi

percent=$(cat "$bat_path/capacity" 2>/dev/null || echo "0")
status=$(cat "$bat_path/status" 2>/dev/null || echo "Unknown")

class="normal"
if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
    icon="󰂄"
    class="charging"
elif [ "$percent" -le 10 ]; then
    icon="󰁺"
    class="critical"
elif [ "$percent" -le 20 ]; then
    icon="󰁻"
    class="warning"
elif [ "$percent" -le 40 ]; then
    icon="󰁽"
elif [ "$percent" -le 60 ]; then
    icon="󰁿"
elif [ "$percent" -le 80 ]; then
    icon="󰂁"
else
    icon="󰁹"
fi

echo "{\"percent\":$percent,\"status\":\"$status\",\"icon\":\"$icon\",\"class\":\"$class\"}"
