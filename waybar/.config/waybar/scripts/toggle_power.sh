#!/bin/sh
if pgrep -f "power_popup.py" > /dev/null; then
    pkill -f "power_popup.py"
else
    python3 "$HOME/.config/waybar/scripts/power_popup.py" &
fi
