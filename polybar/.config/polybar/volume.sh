#!/usr/bin/env sh

SINK="@DEFAULT_AUDIO_SINK@"

VOLUME=$(wpctl get-volume "$SINK")
PERCENT=$(echo "$VOLUME" | awk '{print int($2 * 100)}')

if echo "$VOLUME" | grep -q MUTED; then
    echo "  muted"
elif [ "$PERCENT" -eq 0 ]; then
    echo "   0%"
else
    echo "    ${PERCENT}%"
fi

