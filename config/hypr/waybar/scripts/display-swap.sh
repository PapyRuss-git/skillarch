#!/bin/bash

# SkillArch Display Swap Script
# Toggle between two monitor configurations

FLAG="/tmp/display-config"

if [ -f "$FLAG" ]; then
    # Switch to Config 1: DVI-I-1=IIYAMA, DVI-I-2=DELL
    hyprctl --batch "\
        keyword monitor DVI-I-1,2560x1440@59.96100,1920x0,1 ; \
        keyword monitor DVI-I-2,1920x1080@60.00000,4480x0,1,transform,3 ; \
        keyword workspace 2,monitor:DVI-I-1,default:true ; \
        keyword workspace 3,monitor:DVI-I-2,default:true ; \
        dispatch moveworkspacetomonitor 2 DVI-I-1 ; \
        dispatch moveworkspacetomonitor 3 DVI-I-2"
    rm "$FLAG"
else
    # Switch to Config 2: DVI-I-2=IIYAMA, DVI-I-1=DELL
    hyprctl --batch "\
        keyword monitor DVI-I-2,2560x1440@59.96100,1920x0,1 ; \
        keyword monitor DVI-I-1,1920x1080@60.00000,4480x0,1,transform,3 ; \
        keyword workspace 2,monitor:DVI-I-2,default:true ; \
        keyword workspace 3,monitor:DVI-I-1,default:true ; \
        dispatch moveworkspacetomonitor 2 DVI-I-2 ; \
        dispatch moveworkspacetomonitor 3 DVI-I-1"
    touch "$FLAG"
fi
