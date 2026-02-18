#!/bin/bash
set -o pipefail
# disk.sh - Output JSON disk usage for root partition (single-shot)

read -r _ _ used _ percent _ < <(df -h / 2>/dev/null | tail -1)
pct=${percent%\%}

if [ "$pct" -gt 90 ]; then
    cls="critical"
elif [ "$pct" -gt 80 ]; then
    cls="warning"
else
    cls="normal"
fi

echo "{\"percent\":${pct:-0},\"used\":\"${used:-?}\",\"icon\":\"󰋊\",\"class\":\"$cls\"}"
