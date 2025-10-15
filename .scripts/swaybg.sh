#!/bin/bash

wallpaper_dir="/home/kome/Pictures/Wallpapers"

while true; do
    wallpaper=$(find "$wallpaper_dir" -type f | shuf -n 1)
    cp $wallpaper ~/.scripts/current_wallpaper.png
    killall swaybg
    swaybg -m fill -i "$wallpaper" -o 0 &
    swaybg -m fill -i "$wallpaper" -o 1 &
    sleep 60
done
