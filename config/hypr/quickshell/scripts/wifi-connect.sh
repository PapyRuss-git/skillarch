#!/bin/bash
# wifi-connect.sh - Connect to WiFi network
# Usage: wifi-connect.sh <SSID>

SSID="$1"
[ -z "$SSID" ] && exit 1

# Check if it's a known network
if nmcli -t -f NAME connection show 2>/dev/null | grep -qxF "$SSID"; then
    nmcli connection up "$SSID" 2>/dev/null
    if [ $? -eq 0 ]; then
        notify-send -a "WiFi" "Connected" "$SSID" 2>/dev/null
    else
        notify-send -a "WiFi" "Failed" "Could not connect to $SSID" 2>/dev/null
    fi
else
    # New network: prompt for password via rofi
    PASS=$(rofi -dmenu -password -p "Password for $SSID" -theme-str 'window {width: 400px;}' 2>/dev/null)
    if [ -n "$PASS" ]; then
        nmcli device wifi connect "$SSID" password "$PASS" 2>/dev/null
        if [ $? -eq 0 ]; then
            notify-send -a "WiFi" "Connected" "$SSID" 2>/dev/null
        else
            notify-send -a "WiFi" "Failed" "Could not connect to $SSID" 2>/dev/null
        fi
    fi
fi
