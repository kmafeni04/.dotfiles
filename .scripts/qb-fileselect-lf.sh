#!/usr/bin/env bash
# qb-fileselect-lf.sh
# set euo pipefail

case "$1" in
  file)
    thetype="file"
  ;;
  files)
    thetype="file"
  ;;
esac


tmpfile=$(mktemp)
CMD="lf -selection-path $tmpfile"
wezterm -e lf -selection-path $tmpfile &

line_count=$(cat $tmpfile | wc -l)
if [ $line_count -gt 1 ] && [ thetype == 'file' ]; then
  notify-send -u critical -i "you choose > 1 file and you should only choose one"
  exit 0
fi

cat $tmpfile
