#!/usr/bin/env sh

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
    sleep 0.5
done

for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar main &
done
