# Omarchy Package

Omarchy-specific home-directory configuration belongs here. It owns Walker and the Omarchy theme hook, and must be Stowed with `common/` on the Omarchy machine:

```bash
stow --target="$HOME" --restow common omarchy
```

It intentionally does not own Fedora's Sway, Waybar, Fuzzel, gtklock, or GNOME configuration. Those belong only to `fedora-home/`.
