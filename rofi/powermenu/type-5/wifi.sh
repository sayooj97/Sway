#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Wi-Fi Manager
#
## Available Styles
#
## style-1   style-2   style-3   style-4   style-5

# Current Theme
dir="$HOME/.config/rofi/wifi-manager/type-5"
theme='style-1'

# CMDs
wifi_status=$(nmcli radio wifi)
wifi_toggle() {
    if [[ "$wifi_status" == "enabled" ]]; then
        nmcli radio wifi off
        notify-send "Wi-Fi" "Wi-Fi turned off"
    else
        nmcli radio wifi on
        notify-send "Wi-Fi" "Wi-Fi turned on"
    fi
}

switch_network() {
    local networks=$(nmcli -f SSID dev wifi list | awk 'NR>1')  # Skip header line
    local selected=$(echo "$networks" | rofi -dmenu -p "Select Wi-Fi Network:")

    if [[ -n "$selected" ]]; then
        nmcli dev wifi connect "$selected"
        notify-send "Wi-Fi" "Connecting to $selected"
    fi
}

# Options
toggle_wifi=''
switch_wifi=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Wi-Fi Manager" \
        -theme ${dir}/${theme}.rasi
}

# Confirmation CMD
confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme ${dir}/${theme}.rasi
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$toggle_wifi\n$switch_wifi" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--toggle' ]]; then
            wifi_toggle
        elif [[ $1 == '--switch' ]]; then
            switch_network
        fi
    else
        exit 0
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $toggle_wifi)
        run_cmd --toggle
        ;;
    $switch_wifi)
        run_cmd --switch
        ;;
esac
