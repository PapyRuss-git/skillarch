#!/bin/bash
# network.sh - Output JSON network status (single-shot for Quickshell Process)
# Detects WiFi or Ethernet connection via nmcli
# Uses LANG=C to avoid locale-dependent output (yes/oui/ja...)

export LANG=C

get_icon() {
    local signal=$1
    if [ "$signal" -ge 80 ]; then echo "󰤨"
    elif [ "$signal" -ge 60 ]; then echo "󰤥"
    elif [ "$signal" -ge 40 ]; then echo "󰤢"
    elif [ "$signal" -ge 20 ]; then echo "󰤟"
    else echo "󰤯"
    fi
}

# Check WiFi via device status (most reliable)
wifi_conn=$(nmcli -t -f TYPE,STATE,CONNECTION device status 2>/dev/null | grep "^wifi:connected:" | head -1)
if [ -n "$wifi_conn" ]; then
    ssid=$(echo "$wifi_conn" | cut -d: -f3-)
    signal=$(nmcli -t -f ACTIVE,SIGNAL device wifi list 2>/dev/null | grep "^yes:" | head -1 | cut -d: -f2)
    signal=${signal:-0}
    icon=$(get_icon "$signal")
    escaped_ssid=$(echo "$ssid" | sed 's/\\/\\\\/g; s/"/\\"/g')
    echo "{\"status\":\"connected\",\"ssid\":\"$escaped_ssid\",\"signal\":$signal,\"icon\":\"$icon\"}"
    exit 0
fi

# Check Ethernet
eth=$(nmcli -t -f TYPE,STATE,CONNECTION device status 2>/dev/null | grep "^ethernet:connected:" | head -1)
if [ -n "$eth" ]; then
    name=$(echo "$eth" | cut -d: -f3-)
    echo "{\"status\":\"connected\",\"ssid\":\"$name\",\"signal\":100,\"icon\":\"󰈀\"}"
    exit 0
fi

echo '{"status":"disconnected","ssid":"","signal":0,"icon":"󰤭"}'
