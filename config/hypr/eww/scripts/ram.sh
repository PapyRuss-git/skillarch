#!/bin/bash
# ram.sh - RAM usage for eww defpoll via free

read -r total used <<< "$(free -m | awk '/^Mem:/ {print $2, $3}')"
if [ "$total" -gt 0 ]; then
    percent=$((used * 100 / total))
else
    percent=0
fi

echo "{\"percent\":$percent,\"used\":$used,\"total\":$total,\"icon\":\"󰍛\"}"
