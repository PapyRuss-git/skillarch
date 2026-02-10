#!/bin/bash
# temperature.sh - CPU temperature for eww defpoll

temp_raw=$(sensors 2>/dev/null | grep -m1 'Package id 0' | awk -F'[+.]' '{print $2}')

if [ -z "$temp_raw" ]; then
    # Fallback: read from thermal zone
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp_raw=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
    else
        echo '{"temp":0,"icon":"󰔏","class":"normal"}'
        exit 0
    fi
fi

if [ "$temp_raw" -gt 85 ]; then
    class="critical"
elif [ "$temp_raw" -gt 70 ]; then
    class="warning"
else
    class="normal"
fi

echo "{\"temp\":${temp_raw},\"icon\":\"󰔏\",\"class\":\"${class}\"}"
