#!/bin/bash
# wifi-list.sh - Output JSON array of available WiFi networks (single-shot)
export LANG=C

get_icon() {
    local signal=${1:-0}
    [[ ! "$signal" =~ ^[0-9]+$ ]] && signal=0
    if [ "$signal" -ge 80 ]; then echo "󰤨"
    elif [ "$signal" -ge 60 ]; then echo "󰤥"
    elif [ "$signal" -ge 40 ]; then echo "󰤢"
    elif [ "$signal" -ge 20 ]; then echo "󰤟"
    else echo "󰤯"
    fi
}

# Check if WiFi is enabled
wifi_status=$(nmcli radio wifi 2>/dev/null)
if [ "$wifi_status" != "enabled" ]; then
    echo "[]"
    exit 0
fi

# Force a rescan (non-blocking)
nmcli device wifi rescan 2>/dev/null &

# Get current connection
current_ssid=$(nmcli -t -f ACTIVE,SSID device wifi list 2>/dev/null | grep "^yes:" | cut -d: -f2-)

# Get known networks
known_networks=$(nmcli -t -f NAME connection show 2>/dev/null | sort -u)

# Deduplicate: keep strongest signal per SSID
declare -A seen_signals seen_security seen_inuse

# nmcli -t escapes literal ':' as '\:' in values — handle this
while IFS= read -r raw; do
    # Replace escaped colons with placeholder before splitting
    line="${raw//\\:/__COLON__}"
    IFS=: read -r ssid signal security inuse <<< "$line"
    # Restore colons in values
    ssid="${ssid//__COLON__/:}"
    security="${security//__COLON__/:}"
    [ -z "$ssid" ] && continue
    # Ensure signal is numeric
    [[ ! "$signal" =~ ^[0-9]+$ ]] && signal=0

    # Keep strongest signal per SSID
    if [ -n "${seen_signals[$ssid]}" ]; then
        [ "$signal" -le "${seen_signals[$ssid]}" ] 2>/dev/null && continue
    fi
    seen_signals[$ssid]="$signal"
    seen_security[$ssid]="$security"
    seen_inuse[$ssid]="$inuse"
done < <(nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE device wifi list 2>/dev/null)

# Build JSON
result="["
first=true

while IFS= read -r ssid; do
    [ -z "$ssid" ] && continue
    signal="${seen_signals[$ssid]}"
    [[ ! "$signal" =~ ^[0-9]+$ ]] && signal=0
    security="${seen_security[$ssid]}"
    icon=$(get_icon "$signal")

    is_connected=$( [ "$ssid" = "$current_ssid" ] && echo "true" || echo "false" )
    is_known=$( echo "$known_networks" | grep -qxF "$ssid" && echo "true" || echo "false" )

    $first || result+=","
    first=false

    escaped_ssid=$(echo "$ssid" | sed 's/\\/\\\\/g; s/"/\\"/g')
    result+="{\"ssid\":\"$escaped_ssid\",\"signal\":$signal,\"icon\":\"$icon\",\"security\":\"${security:-Open}\",\"connected\":$is_connected,\"known\":$is_known}"
done < <(printf '%s\n' "${!seen_signals[@]}" | sort)

result+="]"
echo "$result"
