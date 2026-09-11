#!/usr/bin/env bash

# Generated values keep tmux aligned with the workstation palette.
source "$HOME/.config/palette/generated/palette.sh"
declare -gA THEME_COLORS=(
    [statusbar-bg]="$PALETTE_PAPER"
    [statusbar-fg]="$PALETTE_INK"

    [session-bg]="$PALETTE_NAVY"
    [session-fg]="$PALETTE_WHITE"
    [session-prefix-bg]="$PALETTE_RUST"
    [session-copy-bg]="$PALETTE_TEAL"

    [window-active-base]="$PALETTE_NAVY"
    [window-inactive-base]="$PALETTE_OVERLAY"

    [pane-border-active]="$PALETTE_NAVY"
    [pane-border-inactive]="$PALETTE_SLATE"

    [ok-base]="$PALETTE_NAVY"
    [good-base]="$PALETTE_GREEN"
    [info-base]="$PALETTE_BLUE"
    [warning-base]="$PALETTE_OCHRE"
    [error-base]="$PALETTE_RED"
    [disabled-base]="$PALETTE_SLATE"

    [message-bg]="$PALETTE_OVERLAY"
    [message-fg]="$PALETTE_INK"
)

export THEME_COLORS
