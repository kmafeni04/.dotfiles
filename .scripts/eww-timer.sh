#!/usr/bin/env bash

readonly MINUTE=60
readonly HOUR=3600

set_time="$(rofi -dmenu -p "Set Timer (hours:minutes:seconds):")"
until [[ $set_time =~ ^[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}$ ]]; do
  [ -z "$set_time" ] && exit
  notify-send "Timer" "Invalid time format"
  set_time="$(rofi -dmenu -p "Set Timer (hours:minutes:seconds):")"
done

hours="$(($(echo "$set_time" | cut -d ':' -f 1) * HOUR))"
minutes="$(($(echo "$set_time" | cut -d ':' -f 2) * MINUTE))"
seconds="$(echo "$set_time" | cut -d ':' -f 3)"

total_time="$((hours + minutes + seconds))"

notify-send "Timer" "Starting Timer"

for ((i = total_time; i > 0; i--)); do
  hours=$((i / HOUR))
  minutes=$(((i % HOUR) / MINUTE))
  seconds=$((i % MINUTE))

  formatted_time=$(printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds")

  sleep 1
  eww update "timerTime=$formatted_time"
done

notify-send "Timer" "Timer Up" -u critical

eww update timerTime="--:--:--"
