#!/usr/bin/env bash

fpath="${1:-.}"
dir=$(dirname "$fpath")

run_command="cd $dir"
run_command="$run_command; pane_id=\$(wezterm cli get-pane-direction up)"
run_command="$run_command; [ -z \"\$pane_id\" ] && clear && read -p 'No editor pane. Press Enter to close:' && exit"
run_command="$run_command; selection=\$(fzf --preview='bat --color=always {}')"
run_command="$run_command; [ -z \"\$selection\" ] && clear && exit"
run_command="$run_command; echo -en \":e \$selection\r\" | wezterm cli send-text --no-paste --pane-id \$pane_id"
run_command="$run_command; wezterm cli activate-pane --pane-id \$pane_id"

pane_id=$(wezterm cli get-pane-direction down)
[ -n "$pane_id" ] && wezterm cli kill-pane --pane-id "$pane_id"
wezterm cli split-pane --bottom --percent 60 bash -c "$run_command" > /dev/null
