#!/usr/bin/env bash

# Exit quietly if picom is not installed
command -v picom >/dev/null 2>&1 || exit 0

# Prevent duplicate instances (i3 reload-safe)
pgrep -x picom >/dev/null && exit 0

BASE_CONF="$HOME/.config/picom/picom.conf"
NVIDIA_CONF="$HOME/.config/picom/picom-nvidia.conf"

ARGS=(--config "$BASE_CONF")

# Append NVIDIA-specific tuning if NVIDIA GPU detected
if lspci | grep -qi nvidia && [ -f "$NVIDIA_CONF" ]; then
  ARGS+=(--config "$NVIDIA_CONF")
fi

exec picom "${ARGS[@]}"
