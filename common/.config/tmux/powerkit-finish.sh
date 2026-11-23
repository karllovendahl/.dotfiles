#!/usr/bin/env bash
# Adjust powerkit's status line for the absolutely centred window list. Run it
# after powerkit renders: after tpm in tmux.conf and after a theme reload.
#
# Powerkit expects the windows to follow the session directly, so it gives the
# session's closing slant the first window's background and resets the window
# list to the left. Centre the list again, and give the slant the bar
# background it actually sits on.

tmux set -g status-justify absolute-centre

# Powerkit sets the copy-mode selection style once, from the theme tmux started
# with; apply the current theme's copy-mode styles instead.
tmux source-file -q "$HOME/.config/theme/current/tmux.conf"

bar_bg="$(tmux show -gv status-style | sed -n 's/.*bg=\(#[0-9a-fA-F]\{6\}\).*/\1/p')"
left="$(tmux show -gv status-left)"
if [[ -n "$bar_bg" && "$left" == *'bg=#{W:'* ]]; then
  tmux set -g status-left "$(printf '%s' "$left" | sed "s|bg=#{W:[^]]*}}\]|bg=$bar_bg]|")"
fi
