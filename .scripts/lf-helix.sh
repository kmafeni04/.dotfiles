pane_id=$(wezterm cli get-pane-direction right)
if [ -z "${pane_id}" ]; then
  pane_id=$(wezterm cli split-pane --right --percent 80)
fi

wezterm cli activate-pane --pane-id $pane_id

fpath="$1"
program=$(wezterm cli list | awk -v pane_id="$pane_id" '$3==pane_id { print $6 }')
if [ "$program" = "hx" ]; then
  echo -e ":o ${fpath}\r" | wezterm cli send-text --pane-id $pane_id --no-paste
else
  echo "hx '${fpath}'" | wezterm cli send-text --pane-id $pane_id --no-paste
fi
