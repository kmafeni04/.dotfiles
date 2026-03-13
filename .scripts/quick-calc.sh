#!/usr/bin/env bash

set -ex

query=$(rofi -dmenu -p 'quick-calc')

if [ -z "$query" ]; then
  exit 1
fi

result=$(lua - 2>/dev/null <<< "print(assert(tonumber($query)))")

action=$(notify-send "quick-calc" "$result" -A copy="Copy answer to clipboard" -A ignore="Ignore")

if [ "$action" == "copy" ]; then
  $HOME/.scripts/clip.sh add "$result"
fi

