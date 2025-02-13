#!/bin/bash

Date=$(date '+Screenshot_20%y-%m-%d_%H:%M:%S')
scrot -F ~/Pictures/Screenshots/$Date.png  && nemo ~/Pictures/Screenshots/$Date.png

