#!/usr/bin/bash

# Options
toggle="󰐎  Play/Pause"
next="  Next"
prev="  Previous"

# Variable passed to rofi
options="$toggle\n$next\n$prev"

chosen="$(echo -e "$options" | rofi -show -p "Player control" -dmenu -selected-row 0)"
case $chosen in
    $toggle)
    playerctl play-pause
        ;;
    $next)
		playerctl next
        ;;
    $prev)
    playerctl previous
        ;;
    esac
