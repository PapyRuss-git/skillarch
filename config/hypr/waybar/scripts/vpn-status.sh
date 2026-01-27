#!/bin/bash
set -euo pipefail

# VPN Status Script for Waybar
# Shows current VPN connection status

# Check for active VPN connections
vpn_connections=$(nmcli connection show --active | grep -E "(vpn|tun|wireguard)" | wc -l)
openvpn_status=$(pgrep -x openvpn > /dev/null && echo "1" || echo "0")
wireguard_status=$(ip link show | grep -q wg && echo "1" || echo "0")

# Check for common VPN interfaces
vpn_interfaces=$(ip link show | grep -E "(tun|tap|wg)" | wc -l)

if [[ $vpn_connections -gt 0 ]] || [[ $openvpn_status == "1" ]] || [[ $wireguard_status == "1" ]] || [[ $vpn_interfaces -gt 0 ]]; then
    # Get VPN connection name if available
    vpn_name=$(nmcli connection show --active | grep -E "(vpn|tun|wireguard)" | head -1 | awk '{print $1}' | cut -c1-10)
    
    if [[ -n "$vpn_name" ]]; then
        echo "🔒 $vpn_name"
        echo "🔒 Connected: $vpn_name"
        echo "connected"
    else
        echo "🔒 VPN"
        echo "🔒 VPN Connected"
        echo "connected"
    fi
else
    echo "🔓 OFF"
    echo "🔓 VPN Disconnected"
    echo "disconnected"
fi