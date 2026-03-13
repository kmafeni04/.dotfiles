#!/usr/bin/env bash

set -x

bspc subscribe node_state | while read -r _ _ _ _ state flag; do
    if [ "$state" != "fullscreen" ]; then
        continue
    fi
    [ "$flag" = "on" ] && eww close-all || eww open bar
done

