#!/usr/bin/env bash

# set -x

readonly MASTER_SIZE=55

bspc subscribe node_{remove,add} desktop_focus | while read -a line; do

  event="${line[0]}"

  desktop="$(bspc query -D -d focused)"
  [ -z "$desktop" ] && continue

  # Get tiled windows
  windows=($(bspc query -N -d "$desktop" -n '.window.tiled.!hidden'))
  count=${#windows[@]}

  ([ "$count" -eq 0 ] || [ "$count" -eq 1 ]) && continue

  # First window is master
  master="${windows[0]}"
  bspc node "$master" -n "@/1"

  # This makes sure all new windows are added at the end of the stack
  if [ "$event" = "node_add" ]; then
    new_window="${line[4]}"
    new_window_found=false
    for ((i = 1; i < count; i++)); do
      if [ "${windows[$i]}" = "$new_window" ]; then
        new_window_found=true
        unset 'windows[i]'
        break
      fi
    done

    if [ "$new_window_found" = true ]; then
      windows=("${windows[@]}") # Shift the array
      windows[$((count - 1))]="$new_window"
    fi
  fi

  for ((i = 1; i < count; i++)); do
    if ([ $((i - 1)) -gt 0 ] && [ $i -lt 3 ]); then
      # Fixes a weird behavior where, if there are only two windows on the screen with one in fullscreen mode,
      # adding a new window breaks the layout.
      bspc node "${windows[$((i - 1))]}" -p south
      bspc node "${windows[$i]}" -n "${windows[$((i - 1))]}"
    fi
    bspc node "${windows[$i]}" -f # Doing this so when I'm closing, the focus follows the stack
    bspc node "${windows[$i]}" -n "@/2"
  done

  # Balance the slave window stack
  bspc node "@/2" -B

  # Get monitor width and calculate
  mon_width="$(bspc query -T -m | jq .rectangle.width -r)"
  master_width=$((mon_width * MASTER_SIZE / 100))

  # Get current master window width
  current_master_width="$(bspc query -T -n "$master" | jq .rectangle.width -r)"

  # Resize master if needed
  if [ -n "$current_master_width" ] && [ -n "$master_width" ]; then
    diff=$((master_width - current_master_width))
    if [ "$diff" -gt 10 ] || [ "$diff" -lt -10 ]; then
      bspc node "$master" --resize right "$diff" 0
    fi
  fi

done
