#!/usr/bin/env bash

# Script to do simple screen recording and video operations

# set -x

rec_dir="$HOME/Videos/rec"
rec_pid="/tmp/rec_pid"
rec_path="/tmp/rec_path"
rec_notif_commands=' -A open="Open-File" -A location="Open-File-Location" -A convert="Convert-File" -A mute="Mute-video"'

perform_action() {
  local action="$1"
  local path="$2"
  local filename="${path%.*}"
  local extension="${path##*.}"
  case "$action" in
    open)
      xdg-open "$path" &
      disown
      ;;
    location)
      $TERMINAL -e $FILEBROWSER "$path" &
      disown
      ;;
    convert)
      local new_extension="$(rofi -dmenu -p "Extension (default:mp4):")"
      [ -z "$new_extension" ] && new_extension="mp4"
      local convert_filename="$filename.$new_extension"
      ffmpeg -i "$path" -c:v copy -c:a aac "$convert_filename"
      [ $? -ne 0 ] && notify-send "Rec" "Failed to convert file" && return 1
      action="$(notify-send "Rec" "File converted to .$new_extension" $rec_notif_commands)"
      perform_action "$action" "$convert_filename"
      ;;
    mute)
      local muted_filename="$filename-muted.$extension"
      ffmpeg -i "$path" -c:v copy -an "$muted_filename"
      action="$(notify-send "Rec" "File muted" $rec_notif_commands)"
      perform_action "$action" "$muted_filename"
      ;;
    *) return 1 ;;
  esac
}

rec() {
  mkdir -p "$rec_dir"
  local out="$rec_dir/$(date '+%d-%m-%Y_%H-%M-%S').mkv"

  ffmpeg -f x11grab -i :0 -f pulse -i alsa_output.pci-0000_00_1f.3.analog-stereo.monitor -r 30 -c:v libx264 -preset fast -c:a aac "$out" &

  local pid="$!"
  if ! kill -0 "$pid" 2>/dev/null; then
    notify-send "Rec" "Failed to start recording"
    return 1
  fi

  echo "$pid" >"$rec_pid"
  echo "$out" >"$rec_path"
}

stop() {
  kill -15 "$(cat "$rec_pid")" && rm "$rec_pid"
  local path="$(cat "$rec_path")"

  local action="$(notify-send "Rec" "Recording Ended" $rec_notif_commands)"

  perform_action "$action" "$path"
  rm "$rec_path"
}

action="$1"
path="$2"

case "$action" in
  rec)
    [ -f "$rec_pid" ] && stop || rec
    ;;
  check-recording)
    [ -f "$rec_pid" ] && echo "true" || echo "false"
    ;;
  *)
    perform_action "$action" "$path"
    ;;
esac
