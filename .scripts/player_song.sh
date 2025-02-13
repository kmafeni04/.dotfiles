#!/bin/bash

last_player="$(tail -1 /tmp/player-last)"

if	[ "$(playerctl -p $last_player status)" = "Playing" ]; then
	title=`exec playerctl -p $last_player metadata xesam:title`
	artist=`exec playerctl -p $last_player metadata xesam:artist`
	( echo "$title - $artist" ) &

elif	[ "$(playerctl -p $last_player status)" = "Paused" ]; then
	title=`exec playerctl -p $last_player metadata xesam:title`
	artist=`exec playerctl -p $last_player metadata xesam:artist`
	( echo "(PAUSED) $title - $artist" ) &
else
	echo ""
fi
