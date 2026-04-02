#!/usr/bin/env bash

# set -x

rec_dir="$HOME/Videos/rec"
rec_pid="/tmp/rec_pid"
rec_dest="/tmp/rec_dest"

rec() {
  mkdir -p "$rec_dir"
  local out="$rec_dir/$(date '+%d-%m-%Y_%H-%M-%S').mkv"

  ffmpeg -f x11grab -i :0 -f pulse -i alsa_output.pci-0000_00_1f.3.analog-stereo.monitor -r 60 -c:v libx264 -preset fast -c:a aac "$out" &

  echo "$!" >"$rec_pid"
  echo "$out" >"$rec_dest"

  notify-send "Rec" "Recording Started"
}

stop() {
  kill -15 "$(cat "$rec_pid")" && rm "$rec_pid"
  local dest="$(cat "$rec_dest")"

  local action="$(notify-send "Rec" "Recording Ended" -A open="Open File" -A location="Open File Location" -A convert="Convert File")"

  case "$action" in
    open)
      xdg-open "$dest" &
      disown
      ;;
    location)
      $TERMINAL -e $FILEBROWSER "$dest" &
      disown
      ;;
    convert)
      local query="$(rofi -dmenu -p "Extension (default:mp4):")"
      [ -z "$query" ] && query="mp4"
      convert "$dest" "$query"
      ;;
  esac
  rm "$rec_dest"
}

convert() {
  [ -z "$1" ] && notify-send "Rec" "Convert command requires an input" && return 1

  local input="$1"
  local extension="${2:-mp4}"
  local dest="${input%.mkv}.$extension"

  ffmpeg -i "$input" -c:v copy -c:a aac "$dest"
  [ $? -ne 0 ] && notify-send "Rec" "Failed to convert file" && return 1

  action="$(notify-send "Rec" "File converted to .$extension" -A open="Open File" -A location="Open File Location")"
  case "$action" in
    open)
      xdg-open "$dest" &
      disown
      ;;
    location)
      $TERMINAL -e $FILEBROWSER "$dest" &
      disown
      ;;
  esac
}

case "$1" in
  rec)
    [ -f "$rec_pid" ] && stop || rec
    ;;
  convert)
    convert "$2" "$3"
    ;;
  check-recording)
    [ -f "$rec_pid" ] && echo "true" || echo "false"
    ;;
esac
