old_ws=$(hyprctl -j activeworkspace | jq '.id')
for i in {1..9}; do
  hyprctl dispatch workspace $i
done
hyprctl dispatch workspace $old_ws
