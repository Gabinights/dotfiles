#!/bin/bash
# Espera que a variável WAYLAND_DISPLAY esteja disponível
while [ -z "$WAYLAND_DISPLAY" ]; do
    sleep 0.5
done

killall -q waybar
waybar -c ~/.config/waybar/config.jsonc &
