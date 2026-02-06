#!/bin/bash
# cpu.sh - CPU usage for eww defpoll via /proc/stat

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
total=$((user + nice + system + idle + iowait + irq + softirq + steal))
idle_total=$((idle + iowait))

prev_file="/tmp/.eww_cpu_prev"
if [ -f "$prev_file" ]; then
    read -r prev_total prev_idle < "$prev_file"
    diff_total=$((total - prev_total))
    diff_idle=$((idle_total - prev_idle))
    if [ "$diff_total" -gt 0 ]; then
        usage=$(( (diff_total - diff_idle) * 100 / diff_total ))
    else
        usage=0
    fi
else
    usage=0
fi

echo "$total $idle_total" > "$prev_file"
echo "{\"percent\":$usage,\"icon\":\"󰻠\"}"
