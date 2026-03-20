#!/usr/bin/env bash

compile_command="$@"
[ -z "$1" ] && echo "No command provided" && exit

echo -e ":sh /home/kome/.scripts/helix-run.sh '%{buffer_name}' yes '$compile_command'\r" | wezterm cli send-text --no-paste
