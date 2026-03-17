#!/usr/bin/env sh

set -x # for testing

hist_dir="$HOME/.cache/clip"
hist_file="$hist_dir/hist"
new_line="<:NEWLINE:>"
img_surrond="[:IMAGE:]"

init() {
  mkdir -p "$hist_dir"
  touch "$hist_file"
}

notify() {
  local message="$1"
  notify-send "clip" "$message"
}

write() {
  local multiline="$1"
  [ -z $multiline ] && notify "Nothing to write" && exit 1
  if grep -Fxq -e "$multiline" "$hist_file"; then
    local line="$(grep -Fxon -m 1 -e "$multiline" "$hist_file" | grep -Po -m 1 --color="never" "^\d+")"
    sed -i ""$line" d" "$hist_file"
  fi
  echo "$multiline" >> "$hist_file"
}

replace_newline() {
  local clip="$1"
  [ -z "$clip" ] && exit 0
  # https://github.com/BreadOnPenguins/scripts/blob/1396a09a206dbd6f9a08ffa7a5603e6d55ae5f00/shortcuts-menus/txtcliphist#L15
  # copied cause I don't know sed
  local multiline=$(echo -n "$clip" | sed ':a;N;$!ba;s/\n/'"$new_line"'/g')
  echo -n "$multiline"
}

get_selection() {
  local prompt="$1"
  [ -z "$prompt" ] && exit 1

  local temp_file=$(mktemp 2> /dev/null)
  [ -z "$temp_file" ] && exit 1

  IFS=$'\n' # Set internal field separator to new line
  for line in $(cat "$hist_file"); do
    if [[ "$line" == "$img_surrond"* && "$line" == *"$img_surrond.png" ]]; then
      echo -en "$line\x00icon\x1f$hist_dir/$line\n" >> "$temp_file" # How images get displayed in rofi
    else
      echo "$line" >> "$temp_file"
    fi
  done
  local selection=$(tac "$temp_file" | rofi -theme-str "element-icon { size: 100px; }" -dmenu -i -l 3 -p "$prompt")
  rm "$temp_file"
  echo -n "$selection"
}

copy() {
  local clip=$(xclip -o -selection primary | xclip -i -f -selection clipboard 2> /dev/null)
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    [ -z "$clip" ] && clip=$(wl-paste --primary | wl-copy && wl-paste -n)
    echo -n "$clip" | xclip -i -selection clipboard
  fi
  if [ -z "$clip" ]; then
    notify "Nothing to copy"
    exit 1
  fi
  local multiline="$(replace_newline "$clip")"
  write "$multiline"
  notify "Saved to clipboard"
}

add() {
  local input="$1"
  [ -z "$input" ] && exit 0
  local clip=$(echo -n "$input" | xclip -i -f -selection clipboard 2> /dev/null)
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo -n "$input" | wl-copy
  fi
  local multiline="$(replace_newline "$clip")"
  write "$multiline"
  notify "Saved to clipboard"
}

sel() {
  local selection=$(get_selection "Select clipboard entry:")
  [ -z "$selection" ] && exit 0

  local original=$(echo -n "$selection" | sed "s/$new_line/\n/g")
  if [[ "$selection" == "$img_surrond"* && "$selection" == *"$img_surrond.png" ]]; then
    xclip -selection clipboard -target image/png -i "$hist_dir/$selection"
    [ "$XDG_SESSION_TYPE" == "wayland" ] && wl-copy < "$hist_dir/$selection"
  else
    echo -n "$original" | xclip -i -selection clipboard
    [ "$XDG_SESSION_TYPE" == "wayland" ] && echo -n "$original" | wl-copy
  fi
  write "$selection"
  notify "Selected from clipboard"
}

del() {
  local selection=$(get_selection "Delete clipboard entry:")
  [ -z "$selection" ] && exit 1

  local line="$(grep -Fxon -m 1 -e "$selection" "$hist_file" | grep -Po -m 1 --color="never" "^\d+" 2> /dev/null)"
  [ ${line:-0} -le 0 ] && exit 1
  sed -i ""$line"d" "$hist_file"
  if [[ "$selection" == "$img_surrond"* && "$selection" == *"$img_surrond.png" && -f "$hist_dir/$selection" ]]; then
    rm "$hist_dir/$selection"
  fi
  notify "Deleted from clipboard"
}

recopy() {
  local is_img=""
  local img_from=""
  local multiline=""

  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    is_img="$(wl-paste --list-types | grep png 2> /dev/null)"
    [ -n "$is_img"] && img_from="wayland"
  else
    is_img="$(xclip -selection clipboard -o -t TARGETS | grep png 2> /dev/null)"
    [ -n "$is_img"] && img_from="x11"
  fi

  if [ -n "$is_img" ]; then
    img_name="$img_surrond-$(date '+Copied_20%y-%m-%d_%H:%M:%S')-$img_surrond.png"
    if [ "$img_from" == "wayland" ]; then
      wl-paste -t image/png > "$hist_dir/$img_name"
    else
      xclip -selection clipboard -t image/png -o > "$hist_dir/$img_name"
    fi
    xclip -i -t image/png "$hist_dir/$img_name"
    ([ "$XDG_SESSION_TYPE" == "wayland" ] && wl-copy < "$hist_dir/$img_name")

    write "$img_name"
    notify "Image saved to clipboard"
  else
    clip=$(xclip -o -selection clipboard 2> /dev/null)
    if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
      [ -z "$clip" ] && clip=$(wl-paste -n 2> /dev/null)
    fi
    multiline="$(replace_newline "$clip")"
    write "$multiline"
    notify "Primary selection saved to clipboard"
  fi
}

init
case "$1" in
copy) copy ;;
recopy) recopy ;;
add) add "$2" ;;
sel) sel ;;
del) del ;;
clear) rm -rf "$hist_dir" && init && notify "Clipboard cleared" ;;
*) exit 1 ;;
esac
