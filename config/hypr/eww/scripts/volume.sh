#!/bin/bash
# volume.sh - Real-time volume listener for eww deflisten

get_volume() {
    vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+%' | head -1 | tr -d '%' || echo "0")
    muted=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -oP 'yes|no' || echo "no")

    if [ "$muted" = "yes" ]; then
        icon="󰝟"
    elif [ "$vol" -ge 70 ]; then
        icon="󰕾"
    elif [ "$vol" -ge 30 ]; then
        icon="󰖀"
    else
        icon="󰕿"
    fi

    echo "{\"percent\":$vol,\"muted\":\"$muted\",\"icon\":\"$icon\"}"
}

# Initial output
get_volume

# React to sink changes in real time
pactl subscribe 2>/dev/null | grep --line-buffered "sink" | while read -r _; do
    get_volume
done
