# Dotfiles

This repository is organized for GNU Stow.

## Packages

- `common`: shared shell/editor/terminal config
- `linux`: Linux-specific config packages
- `macos`: macOS-specific config and install helpers
- `exports`: reference files that are kept in git but are not stowed

Each stow package mirrors the final path under `$HOME`.

Examples:

- `common/.config/nvim` -> `~/.config/nvim`
- `common/.zshrc` -> `~/.zshrc`
- `linux/.config/hypr` -> `~/.config/hypr`
- `macos/.config/karabiner/karabiner.json` -> `~/.config/karabiner/karabiner.json`

## Usage

From the repo root:

```bash
stow --target="$HOME" common
```

Add the platform-specific package you want on that machine:

```bash
stow --target="$HOME" linux
stow --target="$HOME" macos
```

Or restow a full machine profile:

```bash
stow --target="$HOME" --restow common linux
stow --target="$HOME" --restow common macos
```

## Notes

- `exports/raycast` is not a stow package. It stores exported config snapshots only.
- `macos-install.sh` bootstraps the current macOS dependency set and then stows `common` and `macos`.
- `macos/Brewfile` remains in the `macos` package because its natural target is `$HOME`.
- `linux-install.sh` bootstraps the current Arch-based Linux dependency set and then stows `common` and `linux`.
- `fedora-install.sh` bootstraps Zsh, Neovim, tmux, WezTerm, Kanata, an i3 desktop session, GNOME with Pop Shell, and an optional Sway session on Fedora. It stows `common` and `linux`; privileged files are installed explicitly from `fedora/etc/`, and GNOME preferences are applied by `fedora/configure-gnome.sh`.

## Fedora terminal setup

Run the installer from a clone of this repository:

```bash
./fedora-install.sh
```

The installer uses WezTerm's official nightly COPR, installs Powerlevel10k and Hack Nerd Font in user space, validates the terminal configs, and changes the login shell to Zsh. It also installs a pinned, checksum-verified Kanata binary and enables the tracked system service that maps Caps Lock to Escape when tapped and Control when held. Neovim manages its own plugins and Mason tools when it is opened normally.

i3 is the primary lightweight tiling session. GNOME with Pop Shell and Sway remain installed as alternatives selected from GDM's gear menu. The tracked i3 configuration uses Super-based Omarchy-style focus, movement, workspaces, floating, closing, terminal, launcher, and locking bindings. Its event-driven display watcher handles kernel DRM hotplug events, clears phantom disconnected outputs, and moves workspaces 1–4 to the active primary display.

i3, GNOME, and Sway use a 40 Hz keyboard repeat after a fast 140 ms delay. GNOME disables Shell animations and keeps dynamic workspaces on the primary monitor, while secondary monitors remain fixed; `Super+1…9/0` switches the primary monitor's workspace and `Super+Space` opens GNOME's application grid. i3 uses Rofi on `Super+Space`. The ThinkPad's star-marked user-defined key controls media: star toggles play/pause, `Shift+Star` skips forward, and `Alt+Shift+Star` goes to the previous track. Sway uses Fedora's maintained configuration with personal overrides from `linux/.config/sway/config.d/99-user.conf`: `Super+H/J/K/L` focuses, `Super+Shift+H/J/K/L` moves windows, `Super+1…9/0` switches workspaces, `Super+Shift+1…9/0` moves windows to workspaces, `Super+T` toggles floating, `Super+W` closes, `Super+Return` opens WezTerm, and `Super+Escape` locks.

Privileged Fedora configuration lives under `fedora/etc/`; rerun `./fedora-install.sh` after changing it. The tracked sudo PAM policy makes terminal `sudo` use Fedora's password-only authentication stack. Fingerprint authentication is disabled globally through Fedora Authselect because i3lock cannot present concurrent password and fingerprint prompts reliably and otherwise stalls on fingerprint verification.

Check or temporarily disable the Kanata remapper with:

```bash
sudo systemctl status kanata
sudo systemctl disable --now kanata
```
