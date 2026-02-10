#!/bin/bash
# wifi-connect.sh - Connect to a WiFi network
# Usage: wifi-connect.sh <SSID>
# If known network: connects directly. If new: prompts password via rofi.

SSID="$1"

if [ -z "$SSID" ]; then
    notify-send "WiFi" "No SSID provided" -i network-wireless 2>/dev/null
    exit 1
fi

# Check if this is a known network
if nmcli -t -f name connection show 2>/dev/null | grep -qxF "$SSID"; then
    # Known network - connect directly
    if nmcli connection up "$SSID" 2>/dev/null; then
        notify-send "WiFi" "Connected to $SSID" -i network-wireless 2>/dev/null
    else
        notify-send "WiFi" "Failed to connect to $SSID" -i network-wireless-error 2>/dev/null
    fi
else
    # New network - prompt for password via rofi
    password=$(rofi -dmenu -password -p "Password for $SSID" -theme-str 'window {width: 400px;}' 2>/dev/null)

    if [ -z "$password" ]; then
        # User cancelled
        exit 0
    fi

    if nmcli device wifi connect "$SSID" password "$password" 2>/dev/null; then
        notify-send "WiFi" "Connected to $SSID" -i network-wireless 2>/dev/null
    else
        notify-send "WiFi" "Failed to connect to $SSID" -i network-wireless-error 2>/dev/null
    fi
fi

for i in 0 1 2 3; do eww close "wifi-popup-$i" 2>/dev/null; done
