# Rendered by theme-render. Edit ~/.config/themed/tmux.conf.tpl instead.
# The clock is neutral, like the Waybar clock.
set -g @powerkit_plugins 'external(""|"$(date +%H:%M)"|"{{ overlay }}"|"{{ overlay }}"|"5")'
set -g @powerkit_active_window_fg '{{ on_focus_fill }}'
set -g @powerkit_inactive_window_fg '{{ foreground }}'
# Copy mode: the selection uses the accent, like Neovim's visual mode; search
# hits are yellow, the current one solid. powerkit-finish.sh applies these
# again after powerkit, which sets its own mode-style.
set -g mode-style 'fg={{ on_accent }},bg={{ accent }}'
set -g copy-mode-match-style 'fg={{ foreground }},bg={{ match_fill }}'
set -g copy-mode-current-match-style 'fg={{ on_accent }},bg={{ color3 }},bold'
# The rest of tmux's own UI, which otherwise uses tmux's or powerkit's default
# colours: the clock (prefix t), pane numbers (prefix q), the session tree
# (prefix s), copy-mode marks and line numbers. -q skips options an older tmux
# does not have.
set -gq clock-mode-colour '{{ foreground }}'
set -gq display-panes-active-colour '{{ foreground }}'
set -gq display-panes-colour '{{ muted }}'
set -gq display-panes-border-style 'fg={{ line }}'
set -gq copy-mode-mark-style 'fg={{ foreground }},bg={{ line }}'
set -gq copy-mode-line-number-style 'fg={{ muted }}'
set -gq copy-mode-current-line-number-style 'fg={{ foreground }}'
set -gq switch-mode-match-style 'fg={{ foreground }},bg={{ match_fill }}'
set -gq tree-mode-border-style 'fg={{ line }}'
set -gq tree-mode-preview-style 'fg=#{?#{||:#{&&:#{pane_format},#{pane_active}},#{&&:#{window_format},#{window_active}}},{{ foreground }},{{ muted }}}'
set -gq pane-scrollbars-style 'bg={{ overlay }},fg={{ muted }},width=1,pad=0'
set -gq fill-character '#{?is_inside,#[bg={{ overlay }}] ,#[fg={{ line }}]#[acs]~}'
