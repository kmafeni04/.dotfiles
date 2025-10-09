#!/usr/bin/bash

# Options
shutdown="⏼  Shutdown"
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
        $LOCK_SCRIPT
        ;;
    $logOut)
        $LOGOUT_SCRIPT
        ;;
esac
