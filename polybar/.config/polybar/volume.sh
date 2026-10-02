#!/usr/bin/env sh

SINK="@DEFAULT_AUDIO_SINK@"

VOLUME=$(wpctl get-volume "$SINK")
PERCENT=$(echo "$VOLUME" | awk '{print int($2 * 100)}')

if echo "$VOLUME" | grep -q MUTED; then
    printf '%%{F#3a698f}v\314\266%%{F-}\n'
elif [ "$PERCENT" -eq 0 ]; then
    printf '%%{F#3a698f}v%%{F-} 0\n'
else
    printf '%%{F#3a698f}v%%{F-} %s\n' "${PERCENT}"
fi
