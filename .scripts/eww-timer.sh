#!/usr/bin/env bash

# set -x

readonly MINUTE=60
readonly HOUR=$((MINUTE * 60))
readonly CURRENT_TIMER_TIME="/tmp/eww-current-timer-time"
readonly CURRENT_TIMER_PID="/tmp/eww-current-timer-pid"

notify() {
  local msg="$1"
  local val="${2:-normal}"
  notify-send 'Timer' "$msg" -u "$val"
}

cancel_timer() {
  if [[ -f $CURRENT_TIMER_PID ]]; then
    kill $(< $CURRENT_TIMER_PID) && rm -f $CURRENT_TIMER_PID && eww update timerTime='--:--:--'
    return "$?"
  else
    notify "No timer to cancel"
    return 1
  fi
}

run_timer() {
  local total_time="$1"

  for ((i = total_time; i > 0; i--)); do
    local hours=$((i / HOUR))
    local minutes=$(((i % HOUR) / MINUTE))
    local seconds=$((i % MINUTE))

    local formatted_time=$(printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds")

    eww update "timerTime=$formatted_time"
    sleep 1
  done

  notify "Timer Up" critical

  return $(cancel_timer)
}

show_menu() {
  if [ "$(eww get timerTime)" != "--:--:--" ]; then
    local choice="$(echo -e "Cancel Timer\nRestart Timer\nSet New Timer\nExit" | rofi -dmenu -p "Timer already running:")"
    case $choice in
    "Cancel Timer")
      cancel_timer || return 1
      notify 'Cancelled Timer'
      ;;
    "Restart Timer")
      cancel_timer || return 1

      notify 'Restarted Timer'
      run_timer $(< "$CURRENT_TIMER_TIME") &
      echo -n "$!" > "$CURRENT_TIMER_PID"
      ;;
    "Set New Timer")
      cancel_timer || return 1
      show_menu
      ;;
    esac
  else
    local set_time="$(rofi -dmenu -p "Set Timer (hh:mm:ss):")"
    until [[ $set_time =~ ^[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}$ ]]; do
      [ -z "$set_time" ] && exit
      notify "Invalid format. Please use hh:mm:ss"
      set_time="$(rofi -dmenu -p "Set Timer (hh:mm:ss):")"
    done

    local hours="$(($(echo "$set_time" | cut -d ':' -f 1) * HOUR))"
    local minutes="$(($(echo "$set_time" | cut -d ':' -f 2) * MINUTE))"
    local seconds="$(echo "$set_time" | cut -d ':' -f 3)"
    local total_time="$((hours + minutes + seconds))"

    echo -n "$total_time" > "$CURRENT_TIMER_TIME"

    notify "Starting Timer"
    run_timer $total_time &
    echo -n "$!" > "$CURRENT_TIMER_PID"
  fi
}

show_menu
