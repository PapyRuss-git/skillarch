#!/bin/bash
# bluetooth.sh - Bluetooth status for eww defpoll
# Adapted from waybar bluetooth-status.sh

if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    echo "{\"status\":\"off\",\"icon\":\"󰂲\",\"text\":\"off\",\"class\":\"off\"}"
    exit 0
fi

connected_devices=$(bluetoothctl devices Connected 2>/dev/null)
device_count=$(echo "$connected_devices" | grep -c "Device" 2>/dev/null || echo "0")
device_count=$(echo "$device_count" | tr -d '\n\r')

if [ "$device_count" -eq 0 ]; then
    echo "{\"status\":\"on\",\"icon\":\"󰂯\",\"text\":\"\",\"class\":\"on\"}"
    exit 0
fi

icon="󰂱"
name=""
battery_info=""

while IFS= read -r line; do
    if [[ $line =~ Device\ ([0-9A-Fa-f:]+)\ (.+) ]]; then
        mac="${BASH_REMATCH[1]}"
        name="${BASH_REMATCH[2]}"
        device_info=$(bluetoothctl info "$mac" 2>/dev/null)

        if echo "$device_info" | grep -qi "Icon: audio-headset\|Icon: audio-headphones\|UUID: Advanced Audio"; then
            icon="󰋋"
        elif echo "$device_info" | grep -qi "Icon: input-mouse"; then
            icon="󰍽"
        elif echo "$device_info" | grep -qi "Icon: input-keyboard"; then
            icon="󰌌"
        fi

        if echo "$device_info" | grep -q "Battery Percentage:"; then
            battery=$(echo "$device_info" | grep "Battery Percentage:" | sed 's/.*(\([0-9]\+\)).*/\1/')
            [ -n "$battery" ] && battery_info=" ${battery}%"
        fi
        break
    fi
done <<< "$connected_devices"

if [ "$device_count" -gt 1 ]; then
    text="${device_count}${battery_info}"
else
    text="${name}${battery_info}"
fi

# Escape double quotes in device name for JSON
text=$(echo "$text" | sed 's/"/\\"/g')

echo "{\"status\":\"connected\",\"icon\":\"$icon\",\"text\":\"$text\",\"class\":\"connected\"}"
