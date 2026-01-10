#!/usr/bin/env sh

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
    sleep 0.5
done

for m in eDP-1 HDMI-1; do
    MONITOR=$m polybar main &
done
