#!/bin/bash
# bluetooth-devices.sh - Bluetooth paired devices list for eww deflisten popup
# Outputs JSON array of paired devices with connection status, battery, icons

get_bt_devices() {
    # Check if bluetooth is powered on
    if ! bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        echo "[]"
        return
    fi

    paired=$(bluetoothctl devices Paired 2>/dev/null)
    if [ -z "$paired" ]; then
        echo "[]"
        return
    fi

    local first=true
    printf "["

    while IFS= read -r line; do
        if [[ $line =~ Device\ ([0-9A-Fa-f:]+)\ (.+) ]]; then
            mac="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"

            # Escape name for JSON
            name=$(echo "$name" | sed 's/\\/\\\\/g; s/"/\\"/g')

            info=$(bluetoothctl info "$mac" 2>/dev/null)

            # Connection status
            if echo "$info" | grep -q "Connected: yes"; then
                connected="true"
            else
                connected="false"
            fi

            # Device type icon
            icon="󰂱"
            if echo "$info" | grep -qiE "Icon: audio-headset|Icon: audio-headphones|UUID: Advanced Audio"; then
                icon="󰋋"
            elif echo "$info" | grep -qi "Icon: input-mouse"; then
                icon="󰍽"
            elif echo "$info" | grep -qi "Icon: input-keyboard"; then
                icon="󰌌"
            elif echo "$info" | grep -qi "Icon: input-gaming"; then
                icon="󰊗"
            elif echo "$info" | grep -qi "Icon: phone"; then
                icon="󰏲"
            fi

            # Battery level
            battery=""
            if echo "$info" | grep -q "Battery Percentage:"; then
                battery=$(echo "$info" | grep "Battery Percentage:" | sed 's/.*(\([0-9]\+\)).*/\1/')
            fi

            if [ "$first" = true ]; then
                first=false
            else
                printf ","
            fi
            printf '{"mac":"%s","name":"%s","connected":%s,"icon":"%s","battery":"%s"}' \
                "$mac" "$name" "$connected" "$icon" "$battery"
        fi
    done <<< "$paired"

    printf "]\n"
}

# Initial output
get_bt_devices

# Monitor bluetoothctl events and refresh
bluetoothctl 2>/dev/null | while IFS= read -r line; do
    case "$line" in
        *"Connected: "*|*"Disconnected"*|*"ServicesResolved"*|*"NEW"*|*"DEL"*|*"CHG"*)
            sleep 1
            get_bt_devices
            ;;
    esac
done
