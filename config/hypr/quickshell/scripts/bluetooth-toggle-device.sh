#!/bin/bash
# bluetooth-toggle-device.sh - Toggle Bluetooth device connection
# Usage: bluetooth-toggle-device.sh <MAC_ADDRESS>

MAC="$1"
[ -z "$MAC" ] && exit 1

connected=$(bluetoothctl info "$MAC" 2>/dev/null | grep "Connected:" | awk '{print $2}')
name=$(bluetoothctl info "$MAC" 2>/dev/null | grep "Name:" | cut -d' ' -f2-)

if [ "$connected" = "yes" ]; then
    bluetoothctl disconnect "$MAC" &>/dev/null
    notify-send -a "Bluetooth" "Disconnected" "$name" 2>/dev/null
else
    bluetoothctl connect "$MAC" &>/dev/null
    notify-send -a "Bluetooth" "Connecting" "$name" 2>/dev/null
fi
