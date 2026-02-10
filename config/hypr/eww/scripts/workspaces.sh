#!/bin/bash
# workspaces.sh - Real-time workspace listener for eww via Hyprland IPC
# Outputs JSON array of workspace states with monitor info for deflisten

get_workspaces() {
    # Get active workspace per monitor: {monitorID: workspaceID}
    active_map=$(hyprctl monitors -j 2>/dev/null | jq -r '[.[] | {(.id|tostring): .activeWorkspace.id}] | add // {}' 2>/dev/null || echo "{}")

    # Get occupied workspaces with their monitor
    occupied=$(hyprctl workspaces -j 2>/dev/null | jq -c '[.[] | {id, monitorID}]' 2>/dev/null || echo "[]")

    result="["
    for i in $(seq 1 10); do
        # Find which monitor this workspace is on (-1 if not occupied)
        mon=$(echo "$occupied" | jq -r ".[] | select(.id == $i) | .monitorID // -1" 2>/dev/null)
        [ -z "$mon" ] && mon=-1

        class="inactive"
        if [ "$mon" != "-1" ]; then
            class="occupied"
            # Check if this workspace is the active one on its monitor
            active_ws=$(echo "$active_map" | jq -r ".\"$mon\" // -1" 2>/dev/null)
            if [ "$active_ws" = "$i" ]; then
                class="active"
            fi
        fi

        [ "$i" -gt 1 ] && result+=","
        result+="{\"id\":$i,\"class\":\"$class\",\"monitor\":$mon}"
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
