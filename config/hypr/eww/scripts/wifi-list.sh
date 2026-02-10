#!/bin/bash
# wifi-list.sh - WiFi network list for eww deflisten popup
# Outputs JSON array of available networks, refreshes on nmcli events

get_wifi_list() {
    # Check if WiFi radio is enabled
    wifi_radio=$(nmcli radio wifi 2>/dev/null)
    if [ "$wifi_radio" != "enabled" ]; then
        echo "[]"
        return
    fi

    # Get known connections
    known_ssids=$(nmcli -t -f name connection show 2>/dev/null)

    # Get available networks: SSID:SIGNAL:SECURITY:ACTIVE
    wifi_raw=$(LC_ALL=C nmcli -t -f ssid,signal,security,active device wifi list --rescan no 2>/dev/null)

    if [ -z "$wifi_raw" ]; then
        echo "[]"
        return
    fi

    # Build JSON array, deduplicate by SSID (keep strongest signal), sort by signal desc
    echo "$wifi_raw" | awk -F: -v known="$known_ssids" '
    BEGIN {
        # Build known SSID lookup
        n = split(known, arr, "\n")
        for (i = 1; i <= n; i++) {
            if (arr[i] != "") known_map[arr[i]] = 1
        }
    }
    {
        ssid = $1
        if (ssid == "" || ssid == "--") next
        signal = $2 + 0
        security = $3
        active = ($4 == "yes") ? "true" : "false"

        # Deduplicate: keep highest signal
        if (!(ssid in best_signal) || signal > best_signal[ssid]) {
            best_signal[ssid] = signal
            best_security[ssid] = security
            best_active[ssid] = active
        }
    }
    END {
        # Sort by signal (collect into arrays, then bubble sort)
        i = 0
        for (ssid in best_signal) {
            sorted_ssid[i] = ssid
            sorted_signal[i] = best_signal[ssid]
            i++
        }
        count = i

        # Bubble sort descending by signal
        for (i = 0; i < count - 1; i++) {
            for (j = 0; j < count - i - 1; j++) {
                if (sorted_signal[j] < sorted_signal[j+1]) {
                    tmp = sorted_signal[j]; sorted_signal[j] = sorted_signal[j+1]; sorted_signal[j+1] = tmp
                    tmp = sorted_ssid[j]; sorted_ssid[j] = sorted_ssid[j+1]; sorted_ssid[j+1] = tmp
                }
            }
        }

        # Build JSON
        printf "["
        for (i = 0; i < count; i++) {
            ssid = sorted_ssid[i]
            signal = best_signal[ssid]
            security = best_security[ssid]
            active = best_active[ssid]
            is_known = (ssid in known_map) ? "true" : "false"

            # Signal icon
            if (signal >= 75) icon = "󰤨"
            else if (signal >= 50) icon = "󰤥"
            else if (signal >= 25) icon = "󰤢"
            else icon = "󰤟"

            # Escape SSID for JSON
            gsub(/"/, "\\\"", ssid)
            gsub(/\\/, "\\\\", ssid)

            if (i > 0) printf ","
            printf "{\"ssid\":\"%s\",\"signal\":%d,\"security\":\"%s\",\"connected\":%s,\"known\":%s,\"icon\":\"%s\"}", \
                ssid, signal, security, active, is_known, icon
        }
        printf "]"
    }'
    echo
}

# Initial output
get_wifi_list

# Watch for network changes and refresh
nmcli monitor 2>/dev/null | while read -r _; do
    sleep 1
    get_wifi_list
done
