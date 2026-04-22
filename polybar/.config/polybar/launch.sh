#!/usr/bin/env sh

killall -q polybar

while pgrep -u "$UID" -x polybar >/dev/null; do
    sleep 0.2
done

PRIMARY="$(polybar --list-monitors | awk '/ \(primary\)/ {print $1}' | cut -d: -f1)"

for m in $(polybar --list-monitors | cut -d":" -f1); do
    if [ "$m" = "$PRIMARY" ]; then
        MONITOR="$m" polybar main &
    else
        MONITOR="$m" polybar main-secondary &
    fi
done
