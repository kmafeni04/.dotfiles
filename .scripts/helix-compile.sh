#!/bin/sh

compile_command="$@"
[ -z "$compile_command" ] && echo "No command provided" && exit

echo -e ":sh /home/kome/.scripts/helix-run.sh '%{buffer_name}' yes '$compile_command'\r" | wezterm cli send-text --no-paste
