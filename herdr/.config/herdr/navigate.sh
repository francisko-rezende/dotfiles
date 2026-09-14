#!/usr/bin/env bash
# Seamless ctrl+h/j/k/l navigation between herdr panes and Neovim splits.
#
# Bound directly (no prefix) in config.toml to ctrl+h/j/k/l. Herdr intercepts
# these globally, so without this script Neovim would never see the raw key
# and could never move between its own splits first. Mirrors vim-tmux-navigator:
# if the focused pane is running (n)vim, forward the raw key into it so its own
# <C-h/j/k/l> mapping decides (move within vim, or fall through to herdr at the
# edge - see lua/config/keymaps.lua in the nvim package); otherwise move the
# herdr pane focus directly.
set -euo pipefail

direction=$1 # left|right|up|down
key=$2       # ctrl+h, ctrl+j, ctrl+k, ctrl+l

# Herdr injects this into custom command keybindings - it's the pane that was
# focused when the key was pressed, not this script's own (detached) pane.
pane_id="$HERDR_ACTIVE_PANE_ID"
proc=$(herdr pane process-info --pane "$pane_id" | jq -r '.result.process_info.foreground_processes[0].name // empty')

if [[ "$proc" == "nvim" || "$proc" == "vim" ]]; then
  herdr pane send-keys "$pane_id" "$key"
else
  herdr pane focus --direction "$direction" --pane "$pane_id"
fi
