#!/bin/bash

wallpaper_dir="/home/kome/Pictures/Wallpapers"

while true; do
    wallpaper=$(find "$wallpaper_dir" -type f | shuf -n 1)
    cp $wallpaper ~/.scripts/current_wallpaper.png
    nitrogen --set-scaled "$wallpaper" --head=0
    nitrogen --set-scaled "$wallpaper" --head=1
    sleep 60
done


