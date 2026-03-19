#!/usr/bin/env bash

path="$1"

pane_id=$(wezterm cli get-pane-direction up)
if [ -n "${pane_id}" ]; then
  program=$(wezterm cli list | awk -v pane_id="$pane_id" '$3==pane_id { print $6 }')
  if [ "$program" = "hx" ]; then
    echo -e ":o '${path}'\r" | wezterm cli send-text --pane-id $pane_id --no-paste
  else
    wezterm cli kill-pane --pane-id "$pane_id"
    pane_id=$(wezterm cli split-pane --top --percent 70)
    echo "hx '${path}'" | wezterm cli send-text --pane-id $pane_id --no-paste
  fi
else
  pane_id=$(wezterm cli split-pane --top --percent 70)
  echo "hx '${path}'" | wezterm cli send-text --pane-id $pane_id --no-paste
fi

wezterm cli activate-pane --pane-id "$pane_id"
