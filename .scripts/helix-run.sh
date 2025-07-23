#!/bin/sh

filename="$1"
basedir=$(realpath $(dirname "$filename"))
basename=$(basename "$filename")
basename_without_extension="${basename%.*}"
extension="${filename##*.}"

case "$extension" in
  "c")
    run_command="tcc $filename -o $basedir/$basename_without_extension && $basedir/$basename_without_extension"
    ;;
  "nelua")
    run_command="nlpm run nelua --cc=tcc $filename"
    ;;
  "lua")
    run_command="lua $filename"
    ;;
  "ts" | "js")
    run_command="node $filename"
    ;;
  "py")
    run_command="python $filename"
    ;;
  "html")
    run_command="app.zen_browser.zen $basedir/$filename"
    ;;
  "sh")
    run_command="bash $filename"
    ;;
  *)
    echo "No defined case for extension '$extension'"
    run_command=""
    ;;
esac

if [ ! -z "$run_command" ]; then
  pane_id=$(wezterm cli get-pane-direction down)
  if [ -z "${pane_id}" ]; then
    pane_id=$(wezterm cli split-pane --bottom --percent 35)
  fi
  wezterm cli activate-pane --pane-id $pane_id

  echo "${run_command}" | wezterm cli send-text --pane-id $pane_id --no-paste
fi
