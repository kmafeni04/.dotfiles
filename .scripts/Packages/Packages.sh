#!/bin/bash

echo "//System Packages//" > ~/Desktop/Packages.txt
echo "" >> ~/Desktop/Packages.txt
yay -Qet >> ~/Desktop/Packages.txt
echo "" >> ~/Desktop/Packages.txt
echo "//Flatpaks//" >> ~/Desktop/Packages.txt
echo "" >> ~/Desktop/Packages.txt
flatpak list --columns=application >> ~/Desktop/Packages.txt
cat ~/Desktop/Packages.txt


