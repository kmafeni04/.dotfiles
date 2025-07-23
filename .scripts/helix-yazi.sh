pane_id=$(wezterm cli get-pane-direction left)
if [ -z "${pane_id}" ]; then
  pane_id=$(wezterm cli split-pane --left --percent 20)
fi

wezterm cli activate-pane --pane-id $pane_id

program=$(wezterm cli list | awk -v pane_id="$pane_id" '$3==pane_id { print $6 }')
if [ "$program" != "Yazi:" ]; then
  echo "yazi" | wezterm cli send-text --pane-id $pane_id --no-paste
fi
