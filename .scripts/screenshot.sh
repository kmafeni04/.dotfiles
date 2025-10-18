#!/bin/env bash

set -e

name=$(date '+Screenshot_20%y-%m-%d_%H:%M:%S')
screenshot_dir=~/Pictures/screenshots
path="$screenshot_dir/$name.png"
mkdir -p "$screenshot_dir"

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
  grim "$path"
  wl-copy -t image/png < "$path"
else
  scrot "$path"
  xclip -selection clipboard -target image/png -i "$path"
fi

$HOME/.scripts/clip.sh recopy

notify-send "Image saved to '$path'"
