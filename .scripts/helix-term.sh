#!/usr/bin/env bash

set -e

pane_id=$(wezterm cli get-pane-direction down)
[ -n "${pane_id}" ] && wezterm cli kill-pane --pane-id "$pane_id"
pane_id=$(wezterm cli split-pane --bottom --percent 30)

wezterm cli activate-pane --pane-id $pane_id
