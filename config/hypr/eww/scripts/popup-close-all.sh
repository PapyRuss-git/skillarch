#!/bin/bash
# popup-close-all.sh - Close all eww popups and closer windows

for i in 0 1 2 3; do
    eww close "wifi-popup-$i" "bluetooth-popup-$i" "closer-$i" 2>/dev/null
done
