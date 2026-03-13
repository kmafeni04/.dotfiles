#!/bin/env bash

set -e

path="/tmp/temp_screenshot.png"

if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
  case "$1" in
  sel)
    hyprpicker -rz & #For freezing
    PID=$!
    sleep .1
    grim -g "$(slurp)" "$path"
    kill $PID
    ;;
  active)
    grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$path"
    ;;
  full)
    grim -o $(hyprctl activeworkspace -j | jq .monitor -r) "$path"
    ;;
  *)
    exit 1
    ;;
  esac
  wl-copy -t image/png < "$path"
else
  case $1 in
  sel)
    scrot --format png -s -f "$path"
    ;;
  active)
    scrot --format png -w $(bspc query -T -n | jq .id) "$path"
    ;;
  full)
    scrot --format png "$path"
    ;;
  *)
    exit 1
    ;;
  esac
  xclip -selection clipboard -target image/png -i "$path"
fi

$HOME/.scripts/clip.sh recopy
screenshot_action=$(notify-send "Screenshot taken" -A save-to-file="Save Screenshot as file" -A ignore="ignore")

if [ "$screenshot_action" == "save-to-file" ]; then
  dir="$HOME/Pictures/screenshots"
  mkdir -p "$dir"
  screenshot_path="$dir/screenshot-$(date '+%d-%m-%Y-%H:%M:%S').png"
  cp "$path" "$screenshot_path"
  file_action=$(
    notify-send "File saved to $screenshot_path" \
      -A browser="Open Screenshot in filebrowser" \
      -A open="Open Screenshot with default application"
  )
  (
    [ "$file_action" == "browser" ] && $TERMINAL -e $FILEBROWSER $screenshot_path &
    disown
  )
  (
    [ "$file_action" == "open" ] && xdg-open $screenshot_path &
    disown
  )
fi

rm -rf "$path"
