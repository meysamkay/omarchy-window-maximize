#!/bin/bash

# omarchy:summary=Maximize or restore the active Hyprland window without hiding dialogs
# omarchy:group=window
# omarchy:args=[toggle|maximize|restore|status]

set -euo pipefail

action="${1:-toggle}"

active=$(hyprctl activewindow -j 2>/dev/null || echo "{}")
address=$(jq -r '.address // ""' <<<"$active")

if [[ -z "$address" || "$address" == "null" ]]; then
  if [[ "$action" == "status" ]]; then
    echo "none"
  fi
  exit 0
fi

fullscreen=$(jq -r '.fullscreen // 0' <<<"$active")

case "$action" in
  status)
    if [[ "$fullscreen" == "1" ]]; then
      echo "maximized"
    elif [[ "$fullscreen" == "2" || "$fullscreen" == "3" ]]; then
      echo "fullscreen"
    else
      echo "normal"
    fi
    ;;
  maximize)
    if [[ "$fullscreen" != "1" ]]; then
      hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized" })' >/dev/null 2>&1
    fi
    ;;
  restore|unmaximize)
    if [[ "$fullscreen" == "1" ]]; then
      hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized" })' >/dev/null 2>&1
    elif [[ "$fullscreen" == "2" || "$fullscreen" == "3" ]]; then
      hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "fullscreen" })' >/dev/null 2>&1
    fi
    ;;
  toggle|*)
    hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized" })' >/dev/null 2>&1
    ;;
esac
