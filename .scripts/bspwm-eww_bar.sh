#!/usr/bin/env bash

set -x

bspc subscribe node_{state,focus} desktop_focus | while read -a line; do
  subscribed="${line[0]}"

  case "$subscribed" in
  "node_state")
    state="${line[4]}"
    flag="${line[5]}"
    [ "$state" != "fullscreen" ] && continue

    if [ "$flag" = "on" ]; then
      eww close-all
      eww_open="false"
    else
      eww open bar
      eww_open="true"
    fi
    ;;
  "node_focus")
    node="${line[3]}"
    state=$(bspc query -T -n "$node" | jq .client.state -r)

    if [ "$state" = "fullscreen" ]; then
      eww close-all
      eww_open="false"
    elif [ "$eww_open" = "false" ]; then
      eww open bar
      eww_open="true"
    fi
    ;;
  "desktop_focus")
    desktop="${line[2]}"
    root=$(bspc query -T -d "$desktop" | jq .root -r)
    if [ "$root" = "null" ] && [ "$eww_open" = "false" ]; then
      eww open bar
      eww_open="true"
    fi
    ;;
  esac
done
