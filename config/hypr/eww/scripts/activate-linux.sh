#!/bin/bash
# activate-linux.sh - Show "Activate Linux" watermark on all monitors
set -euo pipefail

# Ensure eww daemon is running
if ! pgrep -x eww >/dev/null; then
    eww daemon &
    sleep 0.5
fi

# Get number of monitors from Hyprland
monitor_count=$(hyprctl monitors -j | jq 'length')

# Open watermark on each monitor
for ((i=0; i<monitor_count; i++)); do
    eww open activate-linux-0 --id "activate-linux-$i" --screen "$i" 2>/dev/null || true
done

echo "Activate Linux watermark running on $monitor_count monitor(s)"
