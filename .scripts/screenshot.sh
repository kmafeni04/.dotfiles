#!/bin/env bash

name=$(date '+Screenshot_20%y-%m-%d_%H:%M:%S')
screenshotDir=~/Pictures/screenshots
mkdir -p "$screenshotDir"

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
  grim "$screenshotDir/$name.png"
else
  scrot "$screenshotDir/$name.png"
fi

xclip -selection clipboard -target image/png -i "$screenshotDir/$name.png"

notify-send "$name saved to clipboard and disk"
