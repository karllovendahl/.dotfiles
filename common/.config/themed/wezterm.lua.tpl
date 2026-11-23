-- Rendered by theme-render. Edit ~/.config/themed/wezterm.lua.tpl instead.
return {
  foreground = "{{ foreground }}",
  background = "{{ background }}",
  cursor_bg = "{{ cursor }}",
  cursor_fg = "{{ background }}",
  cursor_border = "{{ cursor }}",
  selection_fg = "{{ selection_foreground }}",
  selection_bg = "{{ selection_background }}",
  scrollbar_thumb = "{{ muted }}",
  split = "{{ line }}",
  ansi = {
    "{{ color0 }}", "{{ color1 }}", "{{ color2 }}", "{{ color3 }}",
    "{{ color4 }}", "{{ color5 }}", "{{ color6 }}", "{{ color7 }}",
  },
  brights = {
    "{{ color8 }}", "{{ color9 }}", "{{ color10 }}", "{{ color11 }}",
    "{{ color12 }}", "{{ color13 }}", "{{ color14 }}", "{{ color15 }}",
  },
}
