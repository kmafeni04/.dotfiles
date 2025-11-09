#!/bin/bash

wallpaper_dir="/home/kome/Pictures/wallpapers"

while true; do
  wallpaper=$(find "$wallpaper_dir" -type f | shuf -n 1)
  cp $wallpaper ~/.scripts/current_wallpaper.png

  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    killall swaybg
    swaybg -m fill -i "$wallpaper" -o "*" &
  else
    for v in $(xrandr --listactivemonitors | grep -P -o "^ \d"); do
      nitrogen --set-scaled "$wallpaper" --head=$v
    done
  fi
  sleep 60
done


