#!/bin/bash
# network.sh - Network status for eww defpoll via nmcli

wifi_info=$(LC_ALL=C nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | grep '^yes' | head -1)

if [ -n "$wifi_info" ]; then
    ssid=$(echo "$wifi_info" | cut -d: -f2)
    signal=$(echo "$wifi_info" | cut -d: -f3)
    if [ "$signal" -ge 75 ]; then
        icon="󰤨"
    elif [ "$signal" -ge 50 ]; then
        icon="󰤥"
    elif [ "$signal" -ge 25 ]; then
        icon="󰤢"
    else
        icon="󰤟"
    fi
    echo "{\"status\":\"connected\",\"ssid\":\"$ssid\",\"signal\":$signal,\"icon\":\"$icon\"}"
elif LC_ALL=C nmcli -t -f type,state dev 2>/dev/null | grep -q 'ethernet:connected'; then
    echo "{\"status\":\"connected\",\"ssid\":\"Ethernet\",\"signal\":100,\"icon\":\"󰈀\"}"
else
    echo "{\"status\":\"disconnected\",\"ssid\":\"\",\"signal\":0,\"icon\":\"󰤭\"}"
fi
