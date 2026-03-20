#!/usr/bin/env bash

set -e

filename="$1"
in_editor="$2"
run_command="$3"

if [ -z "$run_command" ]; then
  basedir=$(realpath "$(dirname "$filename" | sed "s|^~|$HOME|")")
  basename=$(basename "$filename")
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
    run_command="$BROWSER $basedir/$filename"
    ;;
  *)
    echo "No defined case for extension '$extension'"
    run_command=""
    ;;
  esac
fi

[ -z "$run_command" ] && echo "No commnand provided" && exit

if [ -n "$in_editor" ]; then
  run_command="$run_command;source ~/.bash_profile;"
  run_command="$run_command tmp_file=\$(mktemp /tmp/helix-run-open-error.XXXXXXXXXX);"
  run_command="$run_command wezterm cli get-text > \$tmp_file;"
  run_command="$run_command sed -i ':a;N;\$!ba;s/\n\+$//g' \$tmp_file_buffer;"
  run_command="$run_command hx \$tmp_file;"
  run_command="$run_command rm \$tmp_file;"
else
  run_command="$run_command; read -p 'Press Enter to close:'"
fi

pane_id=$(wezterm cli get-pane-direction down)
[ -n "$pane_id" ] && wezterm cli kill-pane --pane-id "$pane_id"
pane_id="$(wezterm cli split-pane --bottom --percent 30 bash -c "$run_command")"
