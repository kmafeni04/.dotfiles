#!/usr/bin/env bash

# Options
shutdown="⏼  Shutdown"
restart="󰜉  Restart"
suspend="󰒲  Suspend"
lock="  Lock"
logOut="󰍃  Log Out"

# Variable passed to rofi
options="$shutdown\n$restart\n$suspend\n$lock\n$logOut"
yes_no="  Yes\n  No"

choice="$(echo -e "$options" | rofi -dmenu -i -p "Power Menu:")"
[ -z "$choice" ] && exit 1

confirm="$(echo -e "$yes_no" | rofi -dmenu -i -p "Are you sure:")"
[ -z "$confirm" ] && exit 1

case $choice in
$shutdown)
  [ "$confirm" = "  Yes" ] && poweroff
  ;;
$restart)
  [ "$confirm" = "  Yes" ] && reboot
  ;;
$suspend)
  [ "$confirm" = "  Yes" ] && systemctl suspend
  ;;
$lock)
  [ "$confirm" = "  Yes" ] && eval "$LOCK_SCRIPT"
  ;;
$logOut)
  [ "$confirm" = "  Yes" ] && pkill -u "$USER"
  ;;
esac
