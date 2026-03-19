#!/usr/bin/env bash

set -x

[ -z "$@" ] && exit 1

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  current_ws="$(hyprctl activeworkspace -j | jq .name -r)"
  [ -z "$current_ws" ] && exit 1
  address="$(hyprctl activewindow -j | jq .address -r)"
  [ -z "$address" ] && exit 1

  hyprctl dispatch movetoworkspacesilent special:swallow,address:$address
  $("$@")
  hyprctl dispatch movetoworkspacesilent name:$current_ws,address:$address
  hyprctl dispatch focuswindow address:$address
else
  wid="$(bspc query -N -n .focused)"
  [ -z "$wid" ] && exit 1

  bspc node "$wid" -g hidden=on
  $("$@")
  bspc node "$wid" -g hidden=off
fi
