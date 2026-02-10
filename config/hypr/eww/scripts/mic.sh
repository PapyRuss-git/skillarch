#!/bin/bash
# mic.sh - Microphone mute status for eww deflisten

get_status() {
    muted=$(pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | awk '{print $2}')
    if [ "$muted" = "yes" ]; then
        echo '{"muted":true,"icon":"󰍭","class":"muted"}'
    else
        echo '{"muted":false,"icon":"󰍬","class":""}'
    fi
}

# Initial state
get_status

# Subscribe to PulseAudio events and update on source changes
pactl subscribe 2>/dev/null | while read -r line; do
    if echo "$line" | grep -q "source"; then
        get_status
    fi
done
