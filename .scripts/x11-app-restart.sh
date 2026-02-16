#!/bin/bash

blueman-applet &
xdman-beta --background &
sleep 5
if pgrep -x "blueman-applet" >/dev/null && pgrep -x "xdm-app" >/dev/null; then
	pkill -x "blueman-applet"
	pkill -x "xdm-app"
	sleep 2
fi

blueman-applet &
xdman-beta --background &
if pgrep -x "blueman-applet" >/dev/null && pgrep -x "xdm-app" >/dev/null; then
	exit 0
fi

counter=0
while [ $counter -lt 10 ]; do
	blueman-applet &
	xdman-beta --background &
	sleep 2
	# Check if success
	if pgrep -x "blueman-applet" >/dev/null && pgrep -x "xdm-app" >/dev/null; then
		exit 0
	fi
	((counter++))
done

if ! pgrep -x "blueman-applet" >/dev/null && ! pgrep -x "xdm-app" >/dev/null; then
	notify-send -u critical "Couldn't start bluetooth tray applet!"
fi
