#!/usr/bin/env bash

# set -x

query="$(rofi -dmenu -p 'quick-calc:')"

[ -z "$query" ] && exit

result="$(lua -e "print(string.format('%.10g', tonumber($query)))" 2>/dev/null)"

[ -z "$result" ] && notify-send "quick-calc" "Invalid expression" && exit 1

action="$(notify-send "quick-calc" "$result" -A copy="Copy answer to clipboard" -A ignore="Ignore")"

[ "$action" == "copy" ] && $HOME/.scripts/clip.sh add "$result"
