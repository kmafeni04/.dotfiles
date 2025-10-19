#!/usr/bin/env sh

set -x # for testing

hist_dir="$HOME/.cache/clip"
hist_file="$hist_dir/hist"
new_line="<:NEWLINE:>"
img_surrond="[:IMAGE:]"

init(){
  mkdir -p "$hist_dir"
  touch "$hist_file"
}

init

write(){
  multiline="$1"
  grep -Fxq -e "$multiline" "$hist_file"
  if [ "$?" -eq 0 ]; then
    line="$(grep -Fxon -m 1 -e "$multiline" "$hist_file" | grep -Po -m 1 --color="never" "^\d+")"
    sed -i ""$line" d" "$hist_file"
  fi
  echo "$multiline" >> "$hist_file"
}

replace_newline(){
  clip="$1"
  [ -z "$clip" ] && exit 0
  # https://github.com/BreadOnPenguins/scripts/blob/1396a09a206dbd6f9a08ffa7a5603e6d55ae5f00/shortcuts-menus/txtcliphist#L15
  # copied cause I don't know sed
  multiline=$(echo "$clip" | sed ':a;N;$!ba;s/\n/'"$new_line"'/g')
  echo "$multiline"
}

copy(){
  clip=$(xclip -o -selection primary | xclip -i -f -selection clipboard 2>/dev/null)
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    [ ! -n "$clip" ] && clip=$(wl-paste --primary | wl-copy && wl-paste -n)
    echo "$clip" | xclip -i -selection clipboard
  fi
  [ ! -n "$clip" ] && (notify-send "Nothing to copy" && exit 0)
  multiline="$(replace_newline "$clip")"
  write "$multiline"
  notification="Copied to clipboard"
}

add(){
  input="$1"
  [ -z "$input" ] && exit 0
  clip=$(echo "$input" | xclip -i -f -selection clipboard 2>/dev/null)
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo "$input"| wl-copy
  fi
  multiline="$(replace_newline "$clip")"
  write "$multiline"
  notification="Copied to clipboard"
}

sel() {
  temp_file="$hist_dir/clip-buffer"
  echo -n "" > $temp_file
  IFS=$'\n'  # Set internal field separator to new line
  for line in $(cat "$hist_file"); do
  if [[ "$line" == "$img_surrond"* && "$line" == *"$img_surrond.png" ]]; then
    echo -en "$line\x00icon\x1f$hist_dir/$line\n" >> $temp_file
  else
    echo -n "$line" >> $temp_file
    echo "" >> $temp_file
  fi
  done
  selection=$(tac "$temp_file" | rofi -theme-str "element-icon { size: 70px; }" -dmenu -p "Clipboard histroy:")
  [ ! -n "$selection" ] && exit 0

  original=$(echo "$selection" | sed "s/$new_line/\n/g")
  if [[ "$selection" == "$img_surrond"* && "$selection" == *"$img_surrond.png" ]]; then
    xclip -selection clipboard -target image/png -i "$hist_dir/$selection"
    [ "$XDG_SESSION_TYPE" == "wayland" ] && wl-copy < "$hist_dir/$img_name"
    notification="Image saved to clipboard"
  else
    echo "$original" | xclip -i -selection clipboard
    [ "$XDG_SESSION_TYPE" == "wayland" ] && echo "$original" | wl-copy
    notification="Copied to clipboard"
  fi
  write "$selection"
}

recopy(){
  is_img=""
  img_from=""
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    is_img="$(wl-paste --list-types | grep png 2>/dev/null)"
  fi
  [ ! -n "$is_img" ] && (is_img="$(xclip -selection clipboard -o -t TARGETS | grep png 2>/dev/null)"; img_from="x11") || img_from="wayland"
  if [ -n "$is_img" ]; then
    img_name="$img_surrond-$(date '+%a_%b%d%y_%h%m%s')-$img_surrond.png"
    if [ "$img_from" == "wayland" ]; then
      wl-paste -t image/png > "$hist_dir/$img_name"
      xclip -i -t image/png "$hist_dir/$img_name"
    else
      xclip -selection clipboard -t image/png -o > "$hist_dir/$img_name"
      [ "$XDG_SESSION_TYPE" == "wayland" ] && wl-copy < "$hist_dir/$img_name"
    fi
    write "$img_name"
    notification="Image saved to clipboard"
  else
    clip=$(xclip -o -selection clipboard 2>/dev/null)
    if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
      [ ! -n "$clip" ] && clip=$(wl-paste | wl-copy && wl-paste -n 2>/dev/null)
      echo "$clip" | xclip -i -selection clipboard
    fi
    multiline="$(replace_newline "$clip")"
    write "$multiline"
    notification="Re copied to clipboard"
  fi
}

case "$1" in
  copy) copy ;;
  recopy) recopy ;;
  add) add "$2" ;;
  sel) sel ;;
  clear) rm -rf "$hist_dir" && init && notification="Clipboard cleared" ;;
  *) exit 1
esac

[ -z "$notification" ] || notify-send "$notification"
