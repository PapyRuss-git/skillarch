#!/bin/bash
# popup-toggle.sh - Toggle a popup on the focused monitor
# Opens a fullscreen invisible "closer" behind the popup for click-outside-to-close
# Usage: popup-toggle.sh <popup-base-name>
# e.g.: popup-toggle.sh wifi-popup

name="$1"
[ -z "$name" ] && exit 1

mon=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.monitorID')
mon=${mon:-0}

# Check if this popup is already open on ANY monitor
if eww active-windows 2>/dev/null | grep -q "^${name}-[0-9]:"; then
    # Close everything
    ~/.config/eww/scripts/popup-close-all.sh
else
    # Close any existing popups first
    ~/.config/eww/scripts/popup-close-all.sh
    # Open closer (invisible fullscreen behind popup) then popup on top
    eww open "closer-${mon}" && eww open "${name}-${mon}"
fi
