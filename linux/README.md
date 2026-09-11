# Linux Package

Linux-specific dotfiles belong here.

This package will mirror final target paths under `$HOME`, for example:

- `.config/i3`
- `.config/sway`
- `.config/waybar`
- `.config/fuzzel`
- `.config/dunst`
- `.config/gtklock`

Helper files for this package live alongside it:

- `../linux-install.sh`: Arch-based bootstrap script for packages, stow, Neovim, and tmux
- `../fedora-install.sh`: Fedora bootstrap, including installation of privileged files tracked under `../fedora/etc/`, GNOME preferences, and a separate Sway session

Fedora uses Sway as the primary lightweight tiling session while keeping i3 and GNOME with Pop Shell available from GDM's login-screen gear menu. Personal Sway fragments layer bindings, output rules, touchpad preferences, and appearance over Fedora's maintained session integration. `.local/bin/sway-display-layout` treats exactly one active non-`eDP-1` display as the external work display: it places that display above the laptop and moves workspaces 1–4 there, irrespective of connector or monitor model; workspace 5 returns to the laptop whenever it is active. With no external display, the laptop returns to `(0,0)`; with multiple external displays, the helper leaves the layout untouched rather than guessing. The closed laptop panel remains a logical Sway output: disabling it creates a zero-output state when the external monitor is disconnected and triggers a gtklock crash in Fedora 44. Logind owns suspension. Application views use subtle `0.96` opacity while layer-shell surfaces such as Waybar, Dunst, and the lock screen remain unaffected. Waybar provides one sharp, light status bar on every active output. A same-named `90-swayidle.conf` user override preserves Fedora's idle, display-power, logind, and before-sleep behavior while routing lock requests through `.local/bin/sway-lock-safe`. That guard starts one gtklock instance, uses a pre-rendered heavily blurred copy of the personal full-resolution wallpaper, and falls back to the original wallpaper or stock swaylock when needed. Refresh the cache after changing the wallpaper with `.local/bin/sway-lock-background-refresh --force`; the Fedora installer also prepares it without delaying the security-sensitive lock path.

The i3 session remains a complete fallback. Its tracked configuration starts the X11 supporting services and uses a DRM/logind watcher to disable stale outputs, place the external display above the laptop panel, and move workspaces 1–4 to the active primary display.

Sway uses a native five-result Fuzzel launcher on `Super+Space`; i3 keeps its Rofi launcher and GNOME uses its normal application grid. Dunst provides sharp light notifications in the lightweight sessions, including Blueman connection status, pairing prompts, and errors. Picom runs a minimal GLX/VSync configuration to prevent X11 screen tearing without shadows, transparency, or fades. Hardware volume and brightness keys use `.local/bin/i3-osd` to show short, replacing Dunst progress notifications. X11 stays at the standard 96 DPI because Xft DPI is global across the whole X session. i3 uses Polybar when installed, with i3bar as a package-safe fallback. Polybar runs normal-sized on the external display and larger on the laptop panel. Applications needing different sizes per monitor require their own zoom controls; X11 cannot apply sharp per-monitor toolkit scaling. GNOME maps the ThinkPad's star-marked user-defined key (`XF86Favorites`) to play/pause, `Shift+Star` to the next track, and `Alt+Shift+Star` to the previous track. i3 provides the same media-key cluster through Playerctl.

The existing i3 theme remains centralized under `.config/theme/`. The active light Sway workstation palette lives in `../common/.config/palette/ink-paper.sh`; `palette-apply` renders its native Sway, Waybar, Fuzzel, Dunst, and gtklock adapters. This keeps active tooling aligned without coupling it to the retained i3/Polybar/Rofi fallback theme.

Wallpaper remains personal state rather than a tracked asset. Set it once with `feh --bg-fill /path/to/wallpaper`; `~/.fehbg` is restored after display changes. The lock background is a cached, blurred PNG generated ahead of locking, and stock i3lock falls back safely when it is absent.

The tracked `numbered-workspaces@dotfiles` GNOME Shell extension moves the clock left, renders numbered dynamic workspaces in the panel center, and restores each workspace's last-focused primary-monitor window after switching. This prevents fixed secondary-monitor windows from stealing focus when returning to a primary-monitor workspace. It also makes notification banners smaller and expires every banner after five seconds, including critical banners; notifications remain available in GNOME's notification center.

Kanata and PAM are system configuration rather than home-directory Stow packages. Their canonical files live under `../fedora/etc/`; the Fedora installer validates and copies them into `/etc`. The sudo PAM policy uses Fedora's password-only authentication stack. Fingerprint authentication is disabled globally through Fedora Authselect so stock i3lock can authenticate with the account password without stalling on an unsupported fingerprint prompt.
