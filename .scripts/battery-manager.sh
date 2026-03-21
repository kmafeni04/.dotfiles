#!/usr/bin/env bash

notify() {
  local msg="$1"
  local val="$2"
  shift 2
  notify-send 'Battery Manager' "$msg" -u "$val" $@
}

while true; do
  current_profile=$(powerprofilesctl | grep '*' | sed -E 's/\*//;s/ //;s/://')
  battery_state=$(upower -i "$(upower -e | grep 'BAT')")

  state="$(echo "$battery_state" | grep state | sed 's/state://;s/ //g')"
  percent="$(echo "$battery_state" | grep percentage | sed 's/percentage://;s/ //g;s/%//')"

  if [ "$state" = "charging" ] || [ "$state" = "fully-charged" ]; then
    [ ! "$current_profile" = "performance" ] && powerprofilesctl set performance && notify "Profile set to 'Performance'" normal
  elif [ "$state" = "discharging" ]; then
    if [ ${percent:-0} -lt 60 ] && [ ! "$current_profile" = "power-saver" ]; then
      powerprofilesctl set power-saver && notify "Profile set to 'Power Saver'" normal
    fi
    if [ ${percent:-0} -lt 40 ]; then
      action=$(notify "Battery Critically Low" critical -A power-options="Check Power Options" -A ignore="Ignore")
      [ "$action" = "power-options" ] && $HOME/.scripts/rofi-power.sh
    fi
  elif [ ! "$current_profile" = "balanced" ]; then
    powerprofilesctl set balanced && notify "Profile set to 'Balanced'" normal
  fi

  sleep 60
done
