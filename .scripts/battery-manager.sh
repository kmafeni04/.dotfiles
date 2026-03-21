#!/usr/bin/env bash

notify() {
  local msg="$1"
  [ -n "$1" ] && shift
  local val="$1"
  [ -n "$1" ] && shift
  notify-send 'Battery Manager' "$msg" -u "$val" $@
}

while true; do
  current_profie=$(powerprofilesctl | grep '*' | sed -E 's/\*//;s/ //;s/://')
  battery_state=$(upower -i "$(upower -e | grep 'BAT')")

  state="$(echo "$battery_state" | grep state | sed 's/ //g' | cut -d : -f 2)"
  percent="$(echo "$battery_state" | grep -o 'percentage:\s*[0-9]*%' | sed 's/percentage://;s/ //g;s/%//')"

  if [ "$state" = "charging" ]; then
    [ ! "$current_profie" = "performace" ] && powerprofilesctl set performace && notify "Profile set to 'Performance'" normal
  elif [ "$state" = "discharging" ] && [ ${percent:-0} -lt 35 ]; then
    [ ! "$current_profie" = "power-saver" ] && powerprofilesctl set power-saver && notify "Profile set to 'Power Saver'" normal
    action=$(notify "Battery Critically Low" critical -A power-options="Check Power Options" -A ignore="Ignore")
    [ "$action" = "power-options" ] && $HOME/.scripts/rofi-power.sh
  else
    [ ! "$current_profie" = "balanced" ] && powerprofilesctl set balanced && notify "Profile set to 'Balanced'" normal
  fi

  sleep 60
done
