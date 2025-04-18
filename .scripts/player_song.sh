#!/bin/bash

if	[ "$(playerctl -p playerctld status -s)" = "Playing" ]; then
	title=`exec playerctl -p playerctld metadata xesam:title`
	artist=`exec playerctl -p playerctld metadata xesam:artist`
	( echo "$title - $artist" ) &
elif	[ "$(playerctl -p playerctld status -s)" = "Paused" ]; then
	title=`exec playerctl -p playerctld metadata xesam:title`
	artist=`exec playerctl -p playerctld metadata xesam:artist`
	( echo "(PAUSED) $title - $artist" ) &
else
	echo ""
fi
