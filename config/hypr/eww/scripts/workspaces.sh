#!/bin/bash
# workspaces.sh - Real-time workspace listener for eww via Hyprland IPC
# Outputs JSON array of workspace states for deflisten

get_workspaces() {
    active=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null || echo "1")
    occupied=$(hyprctl workspaces -j 2>/dev/null | jq -r '.[].id' 2>/dev/null || echo "1")

    result="["
    for i in $(seq 1 10); do
        class="inactive"
        if echo "$occupied" | grep -qw "$i"; then
            class="occupied"
        fi
        if [ "$i" = "$active" ]; then
            class="active"
        fi
        [ "$i" -gt 1 ] && result+=","
        result+="{\"id\":$i,\"class\":\"$class\"}"
    done
    result+="]"
    echo "$result"
}

# Initial output
get_workspaces

# Listen for workspace changes via Hyprland IPC socket
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
socat -u "UNIX-CONNECT:$SOCKET" - 2>/dev/null | while read -r _; do
    get_workspaces
done
