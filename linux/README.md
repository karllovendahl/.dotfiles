# Linux Package

Linux-specific dotfiles belong here.

This package mirrors final target paths under `$HOME`, including:

- `.config/sway`
- `.config/waybar`
- `.config/fuzzel`
- `.config/dunst`
- `.config/gtklock`

Helper files for this package live alongside it:

- `../linux-install.sh`: Arch-based bootstrap script for packages, Stow, Neovim, and tmux
- `../fedora-install.sh`: Fedora bootstrap, including privileged files under `../fedora/etc/`, GNOME preferences, and the Sway session

Fedora uses Sway as the lightweight tiling session, with GNOME and Pop Shell also available from GDM. Personal Sway fragments layer bindings, output rules, touchpad preferences, and appearance over Fedora's maintained session integration. `.local/bin/sway-display-layout` treats exactly one active non-`eDP-1` display as the external work display: it places that display above the laptop and moves workspaces 1–4 there, irrespective of connector or monitor model; workspace 5 returns to the laptop whenever it is active. With no external display, the laptop returns to `(0,0)`; with multiple external displays, the helper leaves the layout untouched rather than guessing. The closed laptop panel remains a logical Sway output: disabling it creates a zero-output state when the external monitor is disconnected and triggers a gtklock crash in Fedora 44. Logind owns suspension. Application views use subtle `0.96` opacity while layer-shell surfaces such as Waybar, Dunst, and the lock screen remain unaffected. Waybar provides one sharp, light status bar on every active output. A same-named `90-swayidle.conf` user override preserves Fedora's idle, display-power, logind, and before-sleep behavior while routing lock requests through `.local/bin/sway-lock-safe`. That guard starts one gtklock instance, uses a pre-rendered heavily blurred copy of the personal full-resolution wallpaper, and falls back to stock swaylock when needed. Refresh the cache after changing the wallpaper with `.local/bin/sway-lock-background-refresh --force`; the Fedora installer also prepares it without delaying the security-sensitive lock path.

Fuzzel is the launcher on `Super+Space`; `wdisplays` opens display controls on `Super+P`; and `Super+Shift+Space` restarts Waybar through `.local/bin/waybar-reload`. The helper stops a stale bar and reloads Sway, whose managed bar launcher starts a fresh instance even when Waybar had crashed. Dunst provides sharp light notifications, including Blueman connection status, pairing prompts, and errors. The active light workstation palette lives in `../common/.config/palette/ink-paper.sh`; `palette-apply` renders its native Sway, Waybar, Fuzzel, Dunst, and gtklock adapters.

XWayland remains installed for individual X11 applications under Sway, but the i3/Xorg desktop, its display tooling, compositor, bar, launcher, screenshot, lock, and legacy theme configuration are intentionally absent.

The tracked `numbered-workspaces@dotfiles` GNOME Shell extension moves the clock left, renders numbered dynamic workspaces in the panel center, and restores each workspace's last-focused primary-monitor window after switching. This prevents fixed secondary-monitor windows from stealing focus when returning to a primary-monitor workspace. It also makes notification banners smaller and expires every banner after five seconds, including critical banners; notifications remain available in GNOME's notification center.

Kanata and sudo PAM are system configuration rather than home-directory Stow packages. Their canonical files live under `../fedora/etc/`; the Fedora installer validates and copies them into `/etc`. The sudo PAM policy uses Fedora's password-only authentication stack.
