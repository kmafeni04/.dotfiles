#!/usr/bin/env bash

declare -A directions
directions["up"]="top"
directions["down"]="bottom"
directions["left"]="left"
directions["right"]="right"

readonly DIRECTION=${1:-"down"}
[ -n "$1" ] && shift
readonly SIZE=${1:-30}
[ -n "$1" ] && shift

pane_id=$(wezterm cli get-pane-direction $DIRECTION)
[ -n "$pane_id" ] && wezterm cli kill-pane --pane-id "$pane_id" || wezterm cli split-pane --percent $SIZE --${directions[$DIRECTION]} $@ > /dev/null
