#!/usr/bin/env bash

compile_command="$@"
[ -z "$1" ] && echo "No command provided" && exit

echo -e ":nop %{/home/kome/.scripts/kak-run.sh '%val{buffile}'} yes '$compile_command'<ret>" | wezterm cli send-text --no-paste
