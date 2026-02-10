#!/bin/bash
# bluetooth-devices.sh - Output JSON array of paired Bluetooth devices (single-shot)

if ! command -v bluetoothctl &>/dev/null; then
    echo "[]"
    exit 0
fi

get_icon() {
    local name="${1,,}"
    if [[ "$name" == *airpods* || "$name" == *headphone* || "$name" == *headset* || "$name" == *buds* || "$name" == *earphone* ]]; then
        echo "󰋋"
    elif [[ "$name" == *mouse* || "$name" == *trackpad* || "$name" == *"mx master"* ]]; then
        echo "󰍽"
    elif [[ "$name" == *keyboard* ]]; then
        echo "󰌌"
    elif [[ "$name" == *gamepad* || "$name" == *controller* || "$name" == *joystick* ]]; then
        echo "󰊗"
    elif [[ "$name" == *phone* || "$name" == *iphone* || "$name" == *galaxy* || "$name" == *pixel* ]]; then
        echo "󰏲"
    elif [[ "$name" == *speaker* ]]; then
        echo "󰓃"
    else
        echo "󰂯"
    fi
}

result="["
first=true

while IFS= read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | cut -d' ' -f3-)
    [ -z "$mac" ] && continue

    # Check if connected
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    connected=$(echo "$info" | grep "Connected:" | awk '{print $2}')
    is_connected=$( [ "$connected" = "yes" ] && echo "true" || echo "false" )

    # Get battery if available (format: "Battery Percentage: 0x3c (60)")
    battery=$(echo "$info" | grep "Battery Percentage:" | grep -oP '\(\K\d+')
    battery_str=""
    [ -n "$battery" ] && battery_str="\"battery\":\"$battery\","

    icon=$(get_icon "$name")

    $first || result+=","
    first=false
    result+="{\"mac\":\"$mac\",\"name\":\"$name\",\"icon\":\"$icon\",\"connected\":$is_connected,${battery_str}\"paired\":true}"
done < <(bluetoothctl devices Paired 2>/dev/null)

result+="]"
echo "$result"
