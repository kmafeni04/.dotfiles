#!/bin/env bash

set -e

path="/tmp/temp_screenshot.png"

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
  case "$1" in
  sel)
    hyprpicker -rz & #For freezing
    PID=$!
    sleep .1
    grim -g "$(slurp)" "$path"
    kill $PID
    ;;
  active)
    grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$path"
    ;;
  full)
    grim -o $(hyprctl activeworkspace -j | jq .monitor -r) "$path"
    ;;
  *)
    exit 1
    ;;
  esac
  wl-copy -t image/png < "$path"
else
  case $1 in
  sel)
    scrot --format png -s -f "$path"
    ;;
  active)
    scrot --format png -w $(bspc query -T -n | jq .id) "$path"
    ;;
  full)
    scrot --format png "$path"
    ;;
  *)
    exit 1
    ;;
  esac
  xclip -selection clipboard -target image/png -i "$path"
fi

notify-send "Screenshot taken"

$HOME/.scripts/clip.sh recopy

rm -rf "$path"
