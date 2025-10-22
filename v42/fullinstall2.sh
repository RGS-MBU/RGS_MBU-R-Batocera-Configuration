#!/bin/bash

read -p "Do you want to install theme Hypermax-Plus-PixN (y/n): " answer1 < /dev/tty
if [[ "$answer1" =~ ^[Yy]$ ]]; then
    mkdir -p /userdata/themes/Hypermax-Plus-PixN
fi

read -p "Do you want to install theme Carbon-PixN (y/n): " answer2 < /dev/tty
if [[ "$answer2" =~ ^[Yy]$ ]]; then
    mkdir -p /userdata/themes/Carbon-PixN
fi


