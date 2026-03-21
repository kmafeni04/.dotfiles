#!/usr/bin/env bash

# set -x

run() {
  if ! pgrep --quiet -f "$1" > /dev/null; then
    "$@" &
    disown
  fi
}

run source $HOME/.bash_profile
run eww open bar
run xrdb $XRESOURCES
run dunst
run caffeine start
run $HOME/.scripts/bg.sh
run $HOME/.scripts/battery-manager.sh
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
