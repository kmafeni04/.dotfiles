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
    app.zen_browser.zen $basedir/$filename
    exit 0
    ;;
  *)
    echo "No defined case for extension '$extension'"
    run_command=""
    ;;
esac

if [ ! -z "$run_command" ]; then
  source ~/.scripts/helix-term.sh

  echo "${run_command}" | wezterm cli send-text --pane-id $pane_id --no-paste
fi
