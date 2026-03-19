#!/bin/sh

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

[ -z "$run_command" ] && echo "No commnand procvided" && exit

source $HOME/.scripts/helix-term.sh
echo "${run_command}" | wezterm cli send-text --pane-id $pane_id --no-paste

if [ -n "$in_editor" ]; then
  sleep 1
  tmp_file_buffer="$(mktemp /tmp/helix-run-open-error.XXXXXXXXXX)"
  tmp_file_final="$(mktemp /tmp/helix-run-open-error.XXXXXXXXXX)"

  echo -e "wezterm cli get-text --start-line 4 > $tmp_file_buffer" | wezterm cli send-text --pane-id $pane_id --no-paste

  sleep 1
  sed -i ':a;N;$!ba;s/\n\+$//g' "$tmp_file_buffer"
  head -n "-1" "$tmp_file_buffer" > "$tmp_file_final"
  rm "$tmp_file_buffer"

  echo -e "hx $tmp_file_final" | wezterm cli send-text --pane-id $pane_id --no-paste

  sleep 1
  rm "$tmp_file_final"
fi
