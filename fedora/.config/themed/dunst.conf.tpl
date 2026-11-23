# Rendered by theme-render. Edit ~/.config/themed/dunst.conf.tpl instead.
[global]
    frame_color = "{{ muted }}"
    # The progress bar (volume, brightness) matches the frame.
    highlight = "{{ muted }}"
    format = "<span foreground='{{ muted }}'><b>[%a]</b></span>\n<b>%s</b>\n%b"

[urgency_low]
    background = "{{ background }}"
    foreground = "{{ muted }}"
    frame_color = "{{ muted }}"
    highlight = "{{ muted }}"

[urgency_normal]
    background = "{{ background }}"
    foreground = "{{ foreground }}"
    frame_color = "{{ muted }}"
    highlight = "{{ muted }}"

[urgency_critical]
    background = "{{ background }}"
    foreground = "{{ foreground }}"
    frame_color = "{{ color1 }}"
    highlight = "{{ color1 }}"
