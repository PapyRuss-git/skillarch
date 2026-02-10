#!/bin/bash
# disk.sh - Root disk usage for eww defpoll

read -r percent used <<< $(df / --output=pcent,used 2>/dev/null | tail -1 | awk '{gsub(/%/,"",$1); printf "%s %s", $1, $2}')

if [ -z "$percent" ]; then
    echo '{"percent":0,"used":"?","icon":"󰋊","class":"normal"}'
    exit 0
fi

# Convert used from 1K blocks to human-readable
used_hr=$(df -h / --output=used 2>/dev/null | tail -1 | awk '{print $1}')

if [ "$percent" -gt 90 ]; then
    class="critical"
elif [ "$percent" -gt 80 ]; then
    class="warning"
else
    class="normal"
fi

echo "{\"percent\":${percent},\"used\":\"${used_hr}\",\"icon\":\"󰋊\",\"class\":\"${class}\"}"
