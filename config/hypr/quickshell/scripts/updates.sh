#!/bin/bash
set -o pipefail
# updates.sh - Output JSON update count (single-shot)

count=0
if command -v checkupdates &>/dev/null; then
    count=$(checkupdates 2>/dev/null | wc -l)
fi

cls="none"
[ "$count" -gt 0 ] && cls="available"

echo "{\"count\":$count,\"icon\":\"󰏗\",\"class\":\"$cls\"}"
