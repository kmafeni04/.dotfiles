#!/bin/bash

wallpaper_dir="/home/kome/Pictures/wallpapers"

while true; do
  wallpaper=$(find "$wallpaper_dir" -type f | shuf -n 1)
  cp $wallpaper ~/.scripts/current_wallpaper.png

  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    killall swaybg
    swaybg -m fill -i "$wallpaper" -o 0 &
    swaybg -m fill -i "$wallpaper" -o 1 &
  else
    nitrogen --set-scaled "$wallpaper" --head=0
    nitrogen --set-scaled "$wallpaper" --head=1
  fi
  sleep 60
done


