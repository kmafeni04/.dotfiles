#!/usr/bin/env sh

set -x # for testing

hist_dir="$HOME/.cache/clip"
hist_file="$hist_dir/hist"
new_line="<:NEWLINE:>"
img_prefix="[:IMAGE:]"

init(){
  mkdir -p "$hist_dir"
  touch "$hist_file"
}

init

write(){
  multiline="$1"
  grep -Fxq -e "$multiline" "$hist_file"
  if [ "$?" -eq 0 ]; then
    line="$(grep -Fxon -m 1 -e "$multiline" "$hist_file" | grep -Po -m 1 --color="never" "\d+:")"
    sed -i ""${line//:/}" d" "$hist_file"
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
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    notification="TODO: wayland add"
    exit 1
  else
    clip=$(xclip -o -selection primary | xclip -i -f -selection clipboard 2>/dev/null)
    multiline="$(replace_newline "$clip")"
  fi
  write "$multiline"
  notification="Copied to clipboard"
}

add(){
  input="$1"
  [ -z "$input" ] && exit 0
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    notify-send "TODO: wayland in"
    exit 1
  else
    clip=$(echo "$input" | xclip -i -f -selection clipboard 2>/dev/null)
    multiline="$(replace_newline "$clip")"
  fi
  write "$multiline"
  notification="Copied to clipboard"
}

sel() {
  selection=$(tac "$hist_file" | rofi -dmenu -p "Clipboard histroy:")
  [ ! -n "$selection" ] && exit 0

  original=$(echo "$selection" | sed "s/$new_line/\n/g")
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    notify-send "TODO: wayland sel"
    exit 1
  else
    if [[ "$selection" == "$img_prefix"* ]]; then
      xclip -selection clipboard -target image/png -i "$hist_dir/$selection"
      notification="Image saved to clipboard"
    else
      echo "$original" | xclip -i -selection clipboard
      notification="Copied to clipboard"
    fi
  fi
  write "$selection"
}

recopy(){
  if [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    notify-send "TODO: wayland readd"
    exit 1
  else
    is_img="$(xclip -selection clipboard -o -t TARGETS | grep png 2>/dev/null)"
    if [ ! -z "$is_img" ]; then
      img_name="$img_prefix-$(date '+%a_%b%d%y_%h%m%s')-$img_prefix.png"
      xclip -selection clipboard -t image/png -o > "$hist_dir/$img_name"
      write "$img_name"
      notification="Image saved to clipboard"
    else
      clip=$(xclip -o -selection clipboard 2>/dev/null)
      multiline="$(replace_newline "$clip")"
      write "$multiline"
      notification="Re copied to clipboard"
    fi
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
