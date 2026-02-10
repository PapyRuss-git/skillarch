#!/bin/bash
# vpn.sh - Output JSON VPN status (single-shot for Quickshell Process)
export LANG=C

# Check nmcli VPN connections
vpn_conn=$(nmcli -t -f TYPE,STATE,NAME connection show --active 2>/dev/null | grep "^vpn:activated:" | head -1)
if [ -n "$vpn_conn" ]; then
    name=$(echo "$vpn_conn" | cut -d: -f3)
    echo "{\"status\":\"connected\",\"icon\":\"󰦝\",\"text\":\"$name\",\"class\":\"connected\"}"
    exit 0
fi

# Check OpenVPN process
if pgrep -x openvpn &>/dev/null; then
    vpn_ip=$(ip -4 addr show tun0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
    echo "{\"status\":\"connected\",\"icon\":\"󰦝\",\"text\":\"${vpn_ip:-VPN}\",\"class\":\"connected\"}"
    exit 0
fi

# Check WireGuard
wg_iface=$(ip link show type wireguard 2>/dev/null | head -1 | awk -F: '{print $2}' | tr -d ' ')
if [ -n "$wg_iface" ]; then
    vpn_ip=$(ip -4 addr show "$wg_iface" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1)
    echo "{\"status\":\"connected\",\"icon\":\"󰦝\",\"text\":\"${vpn_ip:-WG}\",\"class\":\"connected\"}"
    exit 0
fi

echo '{"status":"disconnected","icon":"󰦞","text":"OFF","class":"disconnected"}'
