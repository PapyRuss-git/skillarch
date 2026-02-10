#!/bin/bash
# bluetooth.sh - Output JSON Bluetooth status (single-shot for Quickshell Process)

if ! command -v bluetoothctl &>/dev/null; then
    echo '{"status":"off","icon":"󰂲","text":"","class":"off"}'
    exit 0
fi

powered=$(bluetoothctl show 2>/dev/null | grep "Powered:" | awk '{print $2}')
if [ "$powered" != "yes" ]; then
    echo '{"status":"off","icon":"󰂲","text":"","class":"off"}'
    exit 0
fi

# Count connected devices
connected=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
if [ "$connected" -gt 0 ]; then
    first_name=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)
    echo "{\"status\":\"connected\",\"icon\":\"󰂯\",\"text\":\"$first_name\",\"class\":\"connected\"}"
else
    echo '{"status":"on","icon":"󰂯","text":"","class":"on"}'
fi
