#!/bin/bash

sketchybar -m --add event bluetooth_change "com.apple.bluetooth.status" \
              --add item headphones right \
              --set headphones script="${PLUGIN_DIR}/headphones.sh" label.font="Hack Nerd Font:Regular:8"
              --subscribe headphones bluetooth_change

