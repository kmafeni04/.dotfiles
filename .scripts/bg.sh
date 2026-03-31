#!/usr/bin/env bash

wallpaper_dir="/home/kome/Pictures/wallpapers"
seen=()

while true; do
  mapfile -t wallpapers < <(find "$wallpaper_dir" -type f)

  [ ${#seen[@]} -ge ${#wallpapers[@]} ] && seen=()

  while true; do
    wallpaper=$(printf "%s\n" "${wallpapers[@]}" | shuf -n 1)
    if [[ ! " ${seen[@]} " =~ " $wallpaper " ]]; then
      seen+=("$wallpaper")
      break
    fi
  done

  cp "$wallpaper" /tmp/current_wallpaper.png

  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    killall swaybg
    swaybg -m fill -i "$wallpaper" -o "*" &
  else
    xwallpaper --zoom "$wallpaper" &
  fi
  sleep 60
done
