#!/bin/bash
set -euo pipefail

# Bluetooth Status Script for Waybar
# Shows Bluetooth status with proper device type icons

# Check if Bluetooth is powered on
if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo "󰂲 off"
    echo "󰂲 Bluetooth Off"
    echo "off"
    exit 0
fi

# Get connected devices
connected_devices=$(bluetoothctl devices Connected 2>/dev/null)
device_count=$(echo "$connected_devices" | grep -c "Device" 2>/dev/null || echo "0")
device_count=$(echo "$device_count" | tr -d '\n\r')

if [[ $device_count -eq 0 ]]; then
    echo "󰂯"
    echo "󰂯 Bluetooth On - No devices"
    echo "on"
    exit 0
fi

# Process each connected device to determine icon
icon="📶"  # default
battery_info=""
device_names=()

while IFS= read -r line; do
    if [[ $line =~ Device\ ([0-9A-Fa-f:]+)\ (.+) ]]; then
        mac="${BASH_REMATCH[1]}"
        name="${BASH_REMATCH[2]}"
        device_names+=("$name")
        
        # Get device info to determine type
        device_info=$(bluetoothctl info "$mac" 2>/dev/null)
        
        # Determine icon based on device info
        if echo "$device_info" | grep -qi "Icon: audio-headset\|Icon: audio-headphones\|UUID: Headset\|UUID: Advanced Audio"; then
            icon="🎧"
        elif echo "$device_info" | grep -qi "Icon: input-mouse\|Class.*Mouse"; then
            icon="🖱️"
        elif echo "$device_info" | grep -qi "Icon: input-keyboard\|Class.*Keyboard"; then
            icon="⌨️"
        elif echo "$device_info" | grep -qi "Icon: phone\|Icon: smartphone"; then
            icon="📱"
        elif echo "$device_info" | grep -qi "Icon: computer\|Icon: laptop"; then
            icon="💻"
        elif echo "$device_info" | grep -qi "Icon: audio-speaker"; then
            icon="🔊"
        elif echo "$device_info" | grep -qi "Icon: camera"; then
            icon="📷"
        elif echo "$device_info" | grep -qi "Icon: input-gaming\|gamepad\|joystick"; then
            icon="🎮"
        fi
        
        # Get battery percentage if available
        if echo "$device_info" | grep -q "Battery Percentage:"; then
            battery=$(echo "$device_info" | grep "Battery Percentage:" | sed 's/.*(\([0-9]\+\)).*/\1/')
            if [[ -n "$battery" ]]; then
                battery_info=" ${battery}%"
            fi
        fi
        
        # Use first device for icon (in case of multiple devices)
        break
    fi
done <<< "$connected_devices"

# Output format
if [[ $device_count -gt 1 ]]; then
    echo "${icon} ${device_count}${battery_info}"
    echo "${icon} ${device_count} devices connected${battery_info}"
else
    echo "${icon}${battery_info}"
    echo "${icon} ${device_names[0]}${battery_info}"
fi
echo "connected"