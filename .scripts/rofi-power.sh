#!/usr/bin/bash

# Options
shutdown="⏻  Shutdown"
restart="󰜉 Restart"
suspend="󰒲  Suspend"
lock="  Lock"
logOut="󰍃  Log Out"

# Variable passed to rofi
options="$shutdown\n$restart\n$suspend\n$lock\n$logOut"

chosen="$(echo -e "$options" | rofi -show -p "Power Menu" -dmenu -selected-row 0)"
case $chosen in
    $shutdown)
	 poweroff
        ;;
    $restart)
	reboot
        ;;
    $suspend)
	systemctl suspend
        ;;
    $lock)
		magick /home/kome/.scripts/current_wallpaper.png -resize 1920x /home/kome/.scripts/current_wallpaper.png && i3lock -i /home/kome/.scripts/current_wallpaper.png -ef &
        ;;
    $logOut)
		bspc quit
        ;;
esac
