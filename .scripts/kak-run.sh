#!/usr/bin/env bash

# set -x

filename="$1"
in_fzf="$2"
run_command="$3"

if [ -z "$run_command" ]; then
  basedir="$(realpath "$(dirname "$filename")")"
  basename="$(basename "$filename")"
  basename_without_extension="${basename%.*}"
  extension="${filename##*.}"

  case "$extension" in
  "c")
    run_command="tcc $filename -o $basedir/$basename_without_extension && $basedir/$basename_without_extension"
    ;;
  "nelua")
    run_command="nlpm script dev || nlpm run nelua --cc=tcc $filename"
    ;;
  "lua")
    run_command="lua5.4 $filename || nlpm run nelua --script $filename"
    ;;
  "ts" | "js")
    run_command="node $filename"
    ;;
  "py")
    run_command="python $filename"
    ;;
  "go")
    run_command="go run $filename"
    ;;
  "sh")
    run_command="bash $filename"
    ;;
  "html")
    run_command="python -m http.server 8080 --directory $basedir"
    ;;
  *)
    run_command="No defined case for extension '$extension'"
    ;;
  esac
fi

[ -z "$run_command" ] && echo ": echo 'No commnand provided'<ret>" && exit
[ "$run_command" = "No defined case for extension '$extension'" ] && echo ":echo '$run_command'<ret>" && exit

if [ -n "$in_fzf" ]; then
  run_command="$run_command; pane_id=\$(wezterm cli get-pane-direction up)"
  run_command="$run_command; [ -z \"\$pane_id\" ] && clear && read -p 'No editor pane. Press Enter to close:' && exit"
  run_command="$run_command; choice=\$(wezterm cli get-text | fzf)"
  run_command="$run_command; [ -z \"\$choice\" ] && exit"
  run_command="$run_command; selection=\$(echo \"\$choice\" | grep -P '^\\s*.*?:[0-9]+:?[0-9]*' -o)"
  run_command="$run_command; [ -z \"\$selection\" ] && clear && read -p 'Invalid path. Press Enter to close:' && exit"
  run_command="$run_command; echo -e \":e \$selection\r\" | wezterm cli send-text --no-paste --pane-id \$pane_id"
  run_command="$run_command; wezterm cli activate-pane --pane-id \$pane_id"
else
  run_command="$run_command; read -p 'Press Enter to close:'"
fi

pane_id=$(wezterm cli get-pane-direction down)
[ -n "$pane_id" ] && wezterm cli kill-pane --pane-id "$pane_id"
wezterm cli split-pane --bottom --percent 30 bash -c "$run_command" > /dev/null
