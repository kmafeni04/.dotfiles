#!/usr/bin/env bash

source $HOME/.bash_profile

fpath="$1"

# Check if the number of colons is at least 2
if [[ $(grep -o ':' <<< "$fpath" | wc -l) -ge 2 ]]; then
    pos="$(echo "$fpath" | awk -F: '{print $(NF-1) ":" $NF}')"
    fpath="${fpath/:$pos/}" # Remove pos from fpath
fi

notify-send $pos

pane_id=$(wezterm cli get-pane-direction right)

[ -z "${pane_id}" ] && wezterm cli split-pane --right --percent 80 $EDITOR "$fpath" > /dev/null && exit

wezterm cli activate-pane --pane-id $pane_id

if [ -n "$pos" ]; then
  printf ":e '${fpath}:$pos'\r" | wezterm cli send-text --pane-id $pane_id --no-paste
else
  printf ":e '${fpath}'\r" | wezterm cli send-text --pane-id $pane_id --no-paste
fi
