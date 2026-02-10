#!/bin/bash
# updates.sh - Available system updates for eww defpoll

count=$(checkupdates 2>/dev/null | wc -l)
count=${count:-0}

if [ "$count" -gt 0 ]; then
    class="available"
else
    class="none"
fi

echo "{\"count\":${count},\"icon\":\"󰏗\",\"class\":\"${class}\"}"
