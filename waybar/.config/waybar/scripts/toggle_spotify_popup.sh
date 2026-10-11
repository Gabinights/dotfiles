#!/bin/sh
if pgrep -f "spotify_popup.py" > /dev/null; then
    pkill -f "spotify_popup.py"
else
    python3 "$HOME/.config/waybar/scripts/spotify_popup.py" &
fi
