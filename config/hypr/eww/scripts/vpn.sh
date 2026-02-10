#!/bin/bash
# vpn.sh - VPN status for eww defpoll
# Adapted from waybar vpn-status.sh

vpn_connections=$(nmcli connection show --active 2>/dev/null | grep -cE "(vpn|tun|wireguard)" 2>/dev/null || true)
vpn_connections=${vpn_connections:-0}
openvpn_status=$(pgrep -x openvpn > /dev/null 2>&1 && echo "1" || echo "0")
wireguard_status=$(ip link show 2>/dev/null | grep -q wg && echo "1" || echo "0")
vpn_interfaces=$(ip link show 2>/dev/null | grep -cE "(tun|tap|wg)" 2>/dev/null || true)
vpn_interfaces=${vpn_interfaces:-0}

if [ "$vpn_connections" -gt 0 ] || [ "$openvpn_status" = "1" ] || [ "$wireguard_status" = "1" ] || [ "$vpn_interfaces" -gt 0 ]; then
    # Get the IP from the VPN interface (tun0, wg0, tap0)
    vpn_ip=""
    for iface in tun0 tun1 wg0 wg1 tap0 tap1; do
        vpn_ip=$(ip -4 addr show "$iface" 2>/dev/null | grep -oP 'inet \K[0-9.]+' | head -1)
        [ -n "$vpn_ip" ] && break
    done
    if [ -n "$vpn_ip" ]; then
        echo "{\"status\":\"connected\",\"icon\":\"󰒃\",\"text\":\"$vpn_ip\",\"class\":\"connected\"}"
    else
        echo "{\"status\":\"connected\",\"icon\":\"󰒃\",\"text\":\"VPN\",\"class\":\"connected\"}"
    fi
else
    echo "{\"status\":\"disconnected\",\"icon\":\"󰦞\",\"text\":\"OFF\",\"class\":\"disconnected\"}"
fi
