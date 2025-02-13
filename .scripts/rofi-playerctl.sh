#!/usr/bin/bash

# Options
toggle="󰐎  Play/Pause"
next="  Next"
prev="  Previous"

last_player="$(tail -1 /tmp/player-last)"

# Variable passed to rofi
options="$toggle\n$next\n$prev"

chosen="$(echo -e "$options" | rofi -show -p "Player control" -dmenu -selected-row 0)"
case $chosen in
    $toggle)
		playerctl -p $last_player play-pause
        ;;
    $next)
		playerctl -p $last_player next
        ;;
    $prev)
    playerctl -p $last_player previous
        ;;
    esac
