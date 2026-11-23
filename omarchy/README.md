# Omarchy Package

Omarchy-specific home-directory configuration belongs here. It owns Walker, the Omarchy `theme-set` hook that renders the dotfiles templates after every Omarchy theme switch, and the `ink-paper` user theme link, and must be Stowed with `common/` on the Omarchy machine:

```bash
stow --target="$HOME" --restow common omarchy
```

It intentionally does not own Fedora's Sway, Waybar, Fuzzel, gtklock, or GNOME configuration. Those belong only to `fedora/`.
