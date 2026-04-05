#!/usr/bin/env bash

# set -x

readonly THUMB_DIR="/tmp/hidden_thumbs"
mkdir -p "$THUMB_DIR"
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  readonly META_DIR="/tmp/hidden_meta"
  mkdir -p "$META_DIR"
fi

hide() {
  if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    local current_ws="$(hyprctl activeworkspace -j | jq .name -r)"
    local wid="$(hyprctl activewindow -j | jq .address -r)"
    [ -z "$wid" ] && exit 1
    grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$THUMB_DIR/$wid.png"
    echo -n "$current_ws" >"$META_DIR/$wid"
    hyprctl dispatch movetoworkspacesilent special:hidden,address:$wid
  else
    local wid="$(bspc query -N -n .focused)"
    [ -z "$wid" ] && exit 1
    scrot -w "$wid" -F "$THUMB_DIR/$wid.png"
    bspc node "$wid" -g hidden=on
  fi
}

show() {
  declare -A window_ids
  declare -A window_imgs

  if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    local current_ws="$(hyprctl activeworkspace -j | jq .name -r)"
    for file in "$META_DIR"/*; do
      local ws=$(<"$file")

      local wid="$(basename $file)"
      if [ "$ws" = "$current_ws" ]; then
        local img="$THUMB_DIR/$wid.png"
        [ -f "$img" ] || continue

        local name="$(hyprctl clients -j | jq --arg address "$wid" '.[] | select(.address == $address) | .title' -r)"
        [ -n "$name" ] || continue
        window_ids["$name"]="$wid"
        window_imgs["$name"]="$img"
        entries="$entries$name\x00icon\x1f$img\n"
      fi
    done
  else
    local hidden_wids=($(bspc query -N -d $(bspc query -D -d .focused) -n .hidden))
    local entries=""

    for wid in ${hidden_wids[@]}; do
      local img="$THUMB_DIR/$wid.png"
      [ -f "$img" ] || continue

      local name="$(xprop -id "$wid" WM_NAME | awk -F'\"' '{print $2}')"
      [ -n "$name" ] || continue

      window_ids["$name"]="$wid"
      window_imgs["$name"]="$img"
      entries="$entries$name\x00icon\x1f$img\n"
    done
  fi

  choice=$(printf "%b" "$entries" | rofi -theme-str "element-icon { size: 200px; }" -dmenu -i -l 3 -p "Show window:")
  [ -z "$choice" ] && exit
  if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    [ -n "${window_ids[$choice]}" ] &&
      hyprctl dispatch movetoworkspacesilent name:$current_ws,address:${window_ids[$choice]} &&
      hyprctl dispatch focuswindow address:${window_ids[$choice]}
  else
    [ -n "${window_ids[$choice]}" ] &&
      bspc node "${window_ids[$choice]}" -g hidden=off &&
      bspc node "${window_ids[$choice]}" -f
  fi
  [ -n "${window_imgs[$choice]}" ] && rm -rf "${window_imgs[$choice]}"
}

case "$1" in
  hide) hide ;;
  show) show ;;
esac
