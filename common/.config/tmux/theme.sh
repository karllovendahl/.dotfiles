#!/usr/bin/env bash

# Powerkit colours, keyed to the shared roles in the README: the accent marks
# only the active window, overlay fills the rest, and colour means state.
source "$HOME/.config/theme/current/colors.sh" 2>/dev/null || true
declare -gA THEME_COLORS=(
    [statusbar-bg]="$THEME_BACKGROUND"
    [statusbar-fg]="$THEME_MUTED"

    [session-bg]="$THEME_OVERLAY"
    [session-fg]="$THEME_FOREGROUND"
    [session-prefix-bg]="$THEME_MODE_FILL"
    [session-copy-bg]="$THEME_MODE_FILL"

    [window-active-base]="$THEME_FOCUS_FILL"
    [window-inactive-base]="$THEME_OVERLAY"

    [pane-border-active]="$THEME_MUTED"
    [pane-border-inactive]="$THEME_LINE"

    [ok-base]="$THEME_OVERLAY"
    [good-base]="$THEME_COLOR2"
    [info-base]="$THEME_OVERLAY"
    [warning-base]="$THEME_COLOR3"
    [error-base]="$THEME_COLOR1"
    [disabled-base]="$THEME_OVERLAY"

    [message-bg]="$THEME_OVERLAY"
    [message-fg]="$THEME_FOREGROUND"
)

export THEME_COLORS
