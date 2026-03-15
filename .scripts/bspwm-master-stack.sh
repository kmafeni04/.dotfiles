#!/usr/bin/env bash

set -x

readonly MASTER_SIZE=55

bspc subscribe node_{remove,add,state,flag} | while read -a line; do

  event="${line[0]}"

  desktop=$(bspc query -D -d focused)
  [ -z "$desktop" ] && continue

  # Get tiled windows
  windows=($(bspc query -N -d "$desktop" -n '.window.tiled.!hidden'))
  count=${#windows[@]}

  ([ "$count" -eq 0 ] || [ "$count" -eq 1 ]) && continue

  # First window is master
  master="${windows[0]}"
  bspc node "$master" -n "@/1"

  for ((i = 1; i < count; i++)); do
    slave="${windows[$i]}"
    bspc node "$slave" -n "@/2"
  done

  if [ "$event" = "node_add" ] && ([ "${line[3]}" = "$master" ] || [ "$(bspc query -T -n ${line[3]} | jq .client.state -r)" != "tiled" ]); then
    win="${line[4]}"

    last=$(bspc query -N -d "$desktop" -n '.window.tiled' | tail -1)

    # Preselect south
    bspc node "$last" -p south

    # Move window there
    bspc node "$win" -n "${last}"

    # Cancel preselection
    bspc node "$last" -p cancel
  fi

  # Balance to equal widths in stack
  bspc node "@/2" -B

  # Get monitor width and calculate
  mon_width=$(bspc query -T -m | jq .rectangle.width -r)
  master_width=$((mon_width * MASTER_SIZE / 100))

  # Get current master window width
  current_master_width=$(bspc query -T -n "$master" | jq .rectangle.width -r)

  # Resize if needed
  if [ -n "$current_master_width" ] && [ -n "$master_width" ]; then
    diff=$((master_width - current_master_width))
    if [ "$diff" -gt 10 ] || [ "$diff" -lt -10 ]; then
      bspc node "$master" --resize right "$diff" 0
    fi
  fi

done
