#!/bin/bash

# Get the status of the secondary display
SECONDARY_DISPLAY="HDMI-A-1"
PRIMARY_DISPLAY="eDP-1"

if swaymsg -t get_outputs | grep -q "$SECONDARY_DISPLAY.*disconnected"; then
    swaymsg output $SECONDARY_DISPLAY disable
    swaymsg output $PRIMARY_DISPLAY enable
else
    swaymsg output $PRIMARY_DISPLAY disable
    swaymsg output $SECONDARY_DISPLAY enable
fi
