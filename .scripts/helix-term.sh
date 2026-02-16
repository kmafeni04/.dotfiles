set -e

pane_id=$(wezterm cli get-pane-direction down)
if [ -z "${pane_id}" ]; then
  pane_id=$(wezterm cli split-pane --bottom --percent 30)
fi
wezterm cli activate-pane --pane-id $pane_id
if [ "$#" -ne 0 ]; then
  echo "$@" | wezterm cli send-text --pane-id $pane_id --no-paste
fi
