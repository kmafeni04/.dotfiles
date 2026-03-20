#!/usr/bin/env bash

run() { [ -z $(pgrep -f "$1") ] && "$@" & }

run source $HOME/.bash_profile
run xfce4-power-manager
run eww open bar
run xrdb $XRESOURCES
run dunst
run caffeine start
run $HOME/.scripts/bg.sh
run lua $HOME/.scripts/low_battery.lua
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run dbus-update-activation-environment --systemd --all

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  run dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
else
  run sxhkd
  run xsetroot -cursor_name left_ptr
  run xset led 3 # For generic led keyboards
  run picom
  run redshift
  run $HOME/.scripts/bspwm-eww_bar.sh
  run $HOME/.scripts/bspwm-master-stack.sh

  touchegg_count=$(pgrep -xc touchegg)
  [ "$touchegg_count" -le 1 ] && touchegg & # systemctl start touchegg counts as 1
fi
