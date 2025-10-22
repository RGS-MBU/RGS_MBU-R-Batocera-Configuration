#!/bin/bash

read -p "Do you want to install theme Hypermax-Plus-PixN (y/n): " answer  < /dev/tty
if [[ "$answer" =~ ^[Yy]$ ]]; then
    mkdir -p /userdata/themes/Hypermax-Plus-PixN
fi

read -p "Do you want to install theme Carbon-PixN (y/n): " answer  < /dev/tty
if [[ "$answer" =~ ^[Yy]$ ]]; then
    mkdir -p /userdata/themes/Carbon-PixN
fi


echo -e "Themes installation...."
sleep 1


if [ -d "/userdata/themes/Hypermax-Plus-PixN" ]; then
    echo -e "upgrade Hypermax-Plus-PixN theme"
    /userdata/system/rgs/rclone sync PixN-Themes-New:/update/Themes/Hypermax-Plus-PixN /userdata/themes/Hypermax-Plus-PixN --exclude=/_inc/videos/** --progress
fi

if [ -d "/userdata/themes/Carbon-PixN" ]; then
    echo -e "upgrade Carbon-PixN theme"
    /userdata/system/rgs/rclone sync PixN-Themes-New:/update/Themes/Carbon-PixN /userdata/themes/Carbon-PixN --progress
fi

