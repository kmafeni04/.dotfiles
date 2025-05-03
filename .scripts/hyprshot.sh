#!/bin/bash

Date=$(date '+Screenshot_20%y-%m-%d_%H:%M:%S')
hyprshot -f Screenshots/$Date.png -m output eDP-1 -m active
sleep 1
nemo ~/Pictures/Screenshots/$Date.png --existing-window

