#!/bin/bash
# bluetooth-toggle-device.sh - Toggle connect/disconnect a Bluetooth device
# Usage: bluetooth-toggle-device.sh <MAC>

MAC="$1"

if [ -z "$MAC" ]; then
    notify-send "Bluetooth" "No MAC address provided" -i bluetooth 2>/dev/null
    exit 1
fi

# Get device name for notifications
name=$(bluetoothctl info "$MAC" 2>/dev/null | grep "Name:" | sed 's/.*Name: //')
name="${name:-$MAC}"

# Check if connected
if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
    if bluetoothctl disconnect "$MAC" 2>/dev/null; then
        notify-send "Bluetooth" "Disconnected from $name" -i bluetooth 2>/dev/null
    else
        notify-send "Bluetooth" "Failed to disconnect from $name" -i bluetooth-error 2>/dev/null
    fi
else
    if bluetoothctl connect "$MAC" 2>/dev/null; then
        notify-send "Bluetooth" "Connected to $name" -i bluetooth 2>/dev/null
    else
        notify-send "Bluetooth" "Failed to connect to $name" -i bluetooth-error 2>/dev/null
    fi
fi

for i in 0 1 2 3; do eww close "bluetooth-popup-$i" 2>/dev/null; done
