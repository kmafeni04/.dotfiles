#!/usr/bin/env bash

charge=$(cat /sys/class/power_supply/BAT0/capacity)

icon() {
  if [ "$charge" -le 20 ]; then
    echo -n ""
  elif [ "$charge" -le 40 ]; then
    echo -n ""
  elif [ "$charge" -le 60 ]; then
    echo -n ""
  elif [ "$charge" -le 80 ]; then
    echo -n ""
  else
    echo -n ""
  fi
}

per(){
  echo -n " $charge"
}

case "$1" in
  icon) icon;;
  per) per;;
esac
