pane_id=$(wezterm cli get-pane-direction down)
if [ -z "${pane_id}" ]; then
  pane_id=$(wezterm cli split-pane --bottom --percent 30)
fi
wezterm cli activate-pane --pane-id $pane_id
