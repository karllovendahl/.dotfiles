# Linux Package

Linux-specific dotfiles belong here.

This package will mirror final target paths under `$HOME`, for example:

- `.config/i3`
- `.config/sway`
- `.config/waybar`
- `.config/walker`
- `.config/mako`
- `.config/keyd`

Helper files for this package live alongside it:

- `../linux-install.sh`: Arch-based bootstrap script for packages, stow, Neovim, and tmux
- `../fedora-install.sh`: Fedora bootstrap, including installation of privileged files tracked under `../fedora/etc/`, GNOME preferences, and a separate Sway session

Fedora uses i3 as the primary lightweight tiling session while keeping GNOME with Pop Shell and Sway available from GDM's login-screen gear menu. The tracked `.config/i3/config` starts the small supporting desktop services and defines Super-based Omarchy-style bindings. A small event-driven display watcher listens for kernel DRM hotplug events, disables stale disconnected outputs, places the first connected external display above the laptop panel, and moves workspaces 1–4 to the active primary display. It avoids connector-name assumptions because the dock may expose the same monitor through different DisplayPort names. Fedora's maintained Sway configuration remains available, with `.config/sway/config.d/99-user.conf` layering personal preferences on top.

i3 uses a native five-result Rofi launcher on `Super+Space`; GNOME uses its normal application grid on `Super+Space`. Picom runs a minimal GLX/VSync configuration to prevent X11 screen tearing without shadows, transparency, or fades. Hardware volume and brightness keys use `.local/bin/i3-osd` to show short, replacing Dunst progress notifications. X11 stays at the standard 96 DPI because Xft DPI is global across the whole X session. i3 uses Polybar when installed, with i3bar as a package-safe fallback. Polybar runs normal-sized on the external display and larger on the laptop panel. Applications needing different sizes per monitor require their own zoom controls; X11 cannot apply sharp per-monitor toolkit scaling. GNOME maps the ThinkPad's star-marked user-defined key (`XF86Favorites`) to play/pause, `Shift+Star` to the next track, and `Alt+Shift+Star` to the previous track. i3 provides the same media-key cluster through Playerctl.

Themes are centralized under `.config/theme/`. Theme palettes live in `.config/theme/themes/*.sh`; `.config/theme/current` selects the active theme. Run `.local/bin/theme-apply [theme-name]` after changing a palette. It regenerates the tracked Polybar, Rofi, i3, and Dunst color files, then reloads the visible pieces where possible; theme changes therefore intentionally appear in the dotfiles diff.

Wallpaper remains personal state rather than a tracked asset. Set it once with `feh --bg-fill /path/to/wallpaper`; `~/.fehbg` is restored after display changes. The lock background is a cached, blurred PNG generated ahead of locking, and stock i3lock falls back safely when it is absent.

The tracked `numbered-workspaces@dotfiles` GNOME Shell extension moves the clock left, renders numbered dynamic workspaces in the panel center, and restores each workspace's last-focused primary-monitor window after switching. This prevents fixed secondary-monitor windows from stealing focus when returning to a primary-monitor workspace. It also makes notification banners smaller and expires every banner after five seconds, including critical banners; notifications remain available in GNOME's notification center.

Kanata and PAM are system configuration rather than home-directory Stow packages. Their canonical files live under `../fedora/etc/`; the Fedora installer validates and copies them into `/etc`. The sudo PAM policy uses Fedora's password-only authentication stack. Fingerprint authentication is disabled globally through Fedora Authselect so stock i3lock can authenticate with the account password without stalling on an unsupported fingerprint prompt.
