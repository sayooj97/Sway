#!/usr/bin/env bash

# Starts a scan of available broadcasting SSIDs
# nmcli dev wifi rescan

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FIELDS=SSID,SECURITY
POSITION=0
YOFF=0
XOFF=0
FONT="JetBrains Mono Nerd Font 10"

if [ -r "$DIR/config" ]; then
    source "$DIR/config"
elif [ -r "$HOME/.config/rofi/wifi" ]; then
    source "$HOME/.config/rofi/wifi"
else
    echo "WARNING: config file not found! Using default values."
fi

LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d')
RWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }')+2))
LINENUM=$(echo "$LIST" | wc -l)
KNOWNCON=$(nmcli connection show)
CONSTATE=$(nmcli -fields WIFI g)
CURRSSID=$(LANGUAGE=C nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

if [[ ! -z $CURRSSID ]]; then
    HIGHLINE=$(echo  "$(echo "$LIST" | awk -F "[  ]{2,}" '{print $1}' | grep -Fxn -m 1 "$CURRSSID" | awk -F ":" '{print $1}') + 1" | bc )
fi

if [ "$LINENUM" -gt 8 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
    LINENUM=8
elif [[ "$CONSTATE" =~ "disabled" ]]; then
    LINENUM=1
fi

if [[ "$CONSTATE" =~ "enabled" ]]; then
    TOGGLE="toggle off"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
    TOGGLE="toggle on"
fi

THEME_PATH="$HOME/.config/rofi/wifi-manager/type-5/style-1.rasi"
echo "Theme path: $THEME_PATH"

CHENTRY=$(echo -e "$TOGGLE\nmanual\n$LIST" | uniq -u | rofi -dmenu -p "Wi-Fi SSID: " -lines "$LINENUM" -a "$HIGHLINE" -location "$POSITION" -yoffset "$YOFF" -xoffset "$XOFF" -font "$FONT" -width -"$RWIDTH" -theme "$THEME_PATH")
CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')

if [ "$CHENTRY" = "manual" ] ; then
    MSSID=$(echo "enter the SSID of the network (SSID,password)" | rofi -dmenu -p "Manual Entry: " -font "$FONT" -lines 1)
    MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')
    if [ "$MPASS" = "" ]; then
        nmcli dev wifi con "$MSSID"
    else
        nmcli dev wifi con "$MSSID" password "$MPASS"
    fi

elif [ "$CHENTRY" = "toggle on" ]; then
    nmcli radio wifi on

elif [ "$CHENTRY" = "toggle off" ]; then
    nmcli radio wifi off

else
    if [ "$CHSSID" = "*" ]; then
        CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $3}')
    fi
    if [[ $(echo "$KNOWNCON" | grep "$CHSSID") = "$CHSSID" ]]; then
        nmcli con up "$CHSSID"
    else
        if [[ "$CHENTRY" =~ "WPA2" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
            WIFIPASS=$(echo "if connection is stored, hit enter" | rofi -dmenu -p "password: " -lines 1 -font "$FONT" )
        fi
        nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
    fi
fi
