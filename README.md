# Dotfiles

This repository is organized for GNU Stow.

## Packages

- `common`: shared shell/editor/terminal config
- `fedora`: Fedora Sway, Waybar, lock, launcher, and GNOME home-directory config
- `omarchy`: Omarchy launcher and theme config
- `linux`: compatibility links for existing Stow deployments; do not use for new machines
- `macos`: macOS-specific config and install helpers
- `exports`: reference files that are kept in git but are not stowed

Each stow package mirrors the final path under `$HOME`.

Examples:

- `common/.config/nvim` -> `~/.config/nvim`
- `common/.zshrc` -> `~/.zshrc`
- `fedora/.config/sway` -> `~/.config/sway`
- `omarchy/.config/walker` -> `~/.config/walker`
- `macos/.config/karabiner/karabiner.json` -> `~/.config/karabiner/karabiner.json`

## Usage

From the repo root:

```bash
stow --target="$HOME" common
```

Add the platform-specific package you want on that machine:

```bash
stow --target="$HOME" fedora
stow --target="$HOME" omarchy
stow --target="$HOME" macos
```

Or restow a full machine profile:

```bash
stow --target="$HOME" --restow common fedora
stow --target="$HOME" --restow common omarchy
stow --target="$HOME" --restow common macos
```

## Themes

Theming follows Omarchy's model, so Omarchy themes drop in unchanged:

- **Themes** live in `common/.config/themes/<name>/colors.toml`, in Omarchy's
  format: `background`, `foreground`, `accent`, `cursor`, `selection_*` and
  `color0`–`color15`. A `light.mode` file marks a light theme. A theme may also
  set the chrome keys `surface`, `overlay`, `line`, `muted`, `on_accent` and
  `diff_*`; `theme-render` derives any it leaves out.
- **Templates** live in `<package>/.config/themed/*.tpl`, one per app, using
  Omarchy's `{{ key }}`, `{{ key_strip }}` and `{{ key_rgb }}` placeholders.
  `common` holds WezTerm, Neovim, tmux and prompt templates; `fedora` adds
  Sway, Waybar, Fuzzel, Dunst, gtklock and GTK 4 (libadwaita apps such as
  Files, which pick up colours when they start). Neovim and shell consumers
  read the rendered keys under the same names: `palette.accent` in Lua,
  `$THEME_ACCENT` in `colors.sh`.
- **Wallpapers** live in the theme's `backgrounds/` folder, as in Omarchy.
  The first image is linked as `~/.config/theme/current/background`, which
  Sway and the lock screen use.
- **Output** is rendered to `~/.config/theme/current/`, outside the repository.
  App configs only import from that path, so switching themes never changes
  tracked files.

Every bar and status line uses the colours for the same roles, so the
hierarchy reads the same in Waybar, tmux, Sway and every theme:

| Role | Key | Examples |
|---|---|---|
| Surface | `background` | Waybar, tmux status line |
| Text | `foreground` | clocks, labels, focused workspace number |
| Focus and selection, used rarely | `accent` (tmux fill: `focus_fill`, a dark accent tint on dark themes) | Sway focused window, focused workspace brackets, tmux active window, selections (tmux copy mode, Neovim, Fuzzel), the cursor, the lock screen field and button; the Waybar frame on light themes (set `frame` to override) |
| Everything else | `foreground` or `muted` text, `overlay` fill in tmux | `[ thock ]`, the prompt, tmux session, active pane border, other workspaces and windows, clocks, stats, borders and separators |
| Faint lines | `line` | inactive pane borders, tooltip borders |
| State only | `color1` red, `color2` green, `color3` yellow | battery, muted volume, tmux prefix and copy mode (green tint), search hits (yellow), Neovim insert, visual and replace modes, urgent |

Switch with `theme-set <name>`. The installers
render the current theme once after stowing; on a fresh manual `stow`, run
`theme-set ink-paper` once.

On Omarchy, Omarchy owns switching: `theme-set` calls `omarchy-theme-set`, and
the `theme-set` hook renders the dotfiles templates from Omarchy's current
`colors.toml`. Any Omarchy theme, including ones picked from Omarchy's menu,
therefore also themes WezTerm, Neovim, tmux and the prompt.

## Notes

- `exports/raycast` is not a stow package. It stores exported config snapshots only.
- `macos-install.sh` bootstraps the current macOS dependency set, stows `common` and `macos`, then renders palette adapters.
- `macos/Brewfile` remains in the `macos` package because its natural target is `$HOME`.
- `omarchy-install.sh` bootstraps the current Omarchy/Arch dependency set, stows `common` and `omarchy`, then renders palette adapters.
- `fedora-install.sh` bootstraps Zsh, Neovim, tmux, WezTerm, Kanata, and the Sway desktop session on Fedora. It stows `common` and `fedora`, renders palette adapters, and installs privileged files explicitly from `fedora/etc/`. It does not remove installed packages.
- Fedora and Omarchy installers migrate legacy `linux` Stow links transactionally: they archive affected links, preflight the replacement profile, and restore the archived links if migration fails.

## Fedora terminal setup

Run the installer from a clone of this repository:

```bash
./fedora-install.sh
```

The installer uses WezTerm's official nightly COPR, installs Powerlevel10k and Hack Nerd Font in user space, validates the terminal configs, and changes the login shell to Zsh. It also installs a pinned, checksum-verified Kanata binary and enables the tracked system service that maps Caps Lock to Escape when tapped and Control when held. Neovim manages its own plugins and Mason tools when it is opened normally. Its FFF picker indexes the active buffer's Git root and refuses `$HOME` or `/`, preventing unsafe filesystem-wide native scans.

Sway is the primary tiling session; stock GNOME remains available from GDM's gear menu. Sway uses Fedora's maintained session, portal, and autostart integration with personal output, input, binding, Waybar, gtklock, and `wdisplays` configuration in `fedora/`. A user-level Sway fragment preserves Fedora's idle, display-power, logind, and before-sleep behavior while routing every lock request through one guarded gtklock command. XWayland remains installed so individual X11 applications continue to run under Sway; no X11 desktop session is configured.

Sway uses Fuzzel on `Super+Space`, `wdisplays` on `Super+P`, and a full Waybar restart on `Super+Shift+Space`. The ThinkPad's star-marked user-defined key controls media: star toggles play/pause, `Shift+Star` skips forward, and `Alt+Shift+Star` goes to the previous track. Sway's personal overrides live in `fedora/.config/sway/config.d/`: `Super+H/J/K/L` focuses, `Super+Shift+H/J/K/L` moves windows, `Super+1…9/0` switches workspaces, `Super+Shift+1…9/0` moves and follows windows, `Super+T` toggles floating, `Super+W` closes, `Super+Return` opens WezTerm, `Super+P` opens display controls, `Super+Shift+Space` restarts Waybar, `Super+Shift+S` captures an area and copies it to the clipboard, and `Super+Escape` locks.

Privileged Fedora configuration lives under `fedora/etc/`; rerun `./fedora-install.sh` after changing it. The tracked sudo PAM policy makes terminal `sudo` use Fedora's password-only authentication stack.

Check or temporarily disable the Kanata remapper with:

```bash
sudo systemctl status kanata
sudo systemctl disable --now kanata
```
