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

## Palette

`common/.config/palette/ink-paper.sh` is the single editable light-workstation
palette. Run `palette-apply` after changing it; add `--fedora` on the Fedora
workstation to render its Sway, Waybar, Fuzzel, Dunst, and gtklock adapters.
The shared terminal/editor adapters always render. `palette-apply --check`
reports common-file drift; `palette-apply --fedora --check` also checks the
Fedora adapters. Do not hand-edit generated adapters; edit their palette
template only when a consumer needs a different native format.

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
