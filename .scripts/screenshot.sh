#!/bin/env bash

set -e

path="/tmp/temp_screenshot.png"

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
  case "$1" in
  sel)
    grim -g "$(slurp)" "$path"
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
    notify-send "unimplemented screenshot sel x11"
    exit 0
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
