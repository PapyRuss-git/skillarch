#!/bin/bash
set -euo pipefail

# VPN Toggle Script for Waybar
# Toggles VPN connection on/off

# Check current VPN status
vpn_connections=$(nmcli connection show --active | grep -E "(vpn|tun|wireguard)" | wc -l)

if [[ $vpn_connections -gt 0 ]]; then
    # VPN is active, disconnect it
    vpn_name=$(nmcli connection show --active | grep -E "(vpn|tun|wireguard)" | head -1 | awk '{print $1}')
    nmcli connection down "$vpn_name"
    notify-send "VPN" "Disconnected from $vpn_name" -i network-vpn-symbolic
else
    # No VPN active, show available VPN connections
    vpn_list=$(nmcli connection show | grep -E "(vpn|wireguard)" | awk '{print $1}')
    
    if [[ -n "$vpn_list" ]]; then
        # Use rofi to select VPN connection
        selected_vpn=$(echo "$vpn_list" | rofi -dmenu -p "Select VPN:")
        
        if [[ -n "$selected_vpn" ]]; then
            nmcli connection up "$selected_vpn"
            notify-send "VPN" "Connecting to $selected_vpn" -i network-vpn-symbolic
        fi
    else
        notify-send "VPN" "No VPN connections configured" -i dialog-warning
        # Open network manager for VPN configuration
        nm-connection-editor &
    fi
fi