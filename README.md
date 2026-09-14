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

## Palette

`common/.config/palette/ink-paper.sh` is the single editable light-workstation
palette. Run `palette-apply` after changing it; native adapters for Sway,
Waybar, Fuzzel, Dunst, gtklock, WezTerm, Powerlevel10k, Neovim, and tmux are
rendered from it. `palette-apply --check` reports generated-file drift. Do not
hand-edit generated adapters; edit their palette template only when a consumer
needs a different native format.

## Notes

- `exports/raycast` is not a stow package. It stores exported config snapshots only.
- `macos-install.sh` bootstraps the current macOS dependency set, stows `common` and `macos`, then renders palette adapters.
- `macos/Brewfile` remains in the `macos` package because its natural target is `$HOME`.
- `linux-install.sh` bootstraps the current Arch-based Linux dependency set, stows `common` and `linux`, then renders palette adapters.
- `fedora-install.sh` bootstraps Zsh, Neovim, tmux, WezTerm, Kanata, the Sway desktop session, and GNOME with Pop Shell on Fedora. It stows `common` and `linux`, renders palette adapters, installs privileged files explicitly from `fedora/etc/`, and applies GNOME preferences with `fedora/configure-gnome.sh`. It does not remove installed packages.
- `fedora-retire-i3.sh --confirm` is the one-time, explicit Fedora migration that removes the retired i3/Xorg desktop packages and its old X11-only tools while retaining Sway, GNOME Wayland, and XWayland.

## Fedora terminal setup

Run the installer from a clone of this repository:

```bash
./fedora-install.sh
```

The installer uses WezTerm's official nightly COPR, installs Powerlevel10k and Hack Nerd Font in user space, validates the terminal configs, and changes the login shell to Zsh. It also installs a pinned, checksum-verified Kanata binary and enables the tracked system service that maps Caps Lock to Escape when tapped and Control when held. Neovim manages its own plugins and Mason tools when it is opened normally.

Sway is the lightweight tiling session, alongside GNOME with Pop Shell in GDM's gear menu. Sway uses Fedora's maintained session, portal, and autostart integration with personal output, input, binding, Waybar, gtklock, and `wdisplays` configuration layered on top. A user-level Sway fragment preserves Fedora's idle, display-power, logind, and before-sleep behavior while routing every lock request through one guarded gtklock command. XWayland remains installed so individual X11 applications continue to run under Sway; no X11 desktop session is configured.

GNOME and Sway use a 40 Hz keyboard repeat after a fast 140 ms delay. GNOME disables Shell animations and keeps dynamic workspaces on the primary monitor, while secondary monitors remain fixed; `Super+1…9/0` switches the primary monitor's workspace and `Super+Space` opens GNOME's application grid. Sway uses Fuzzel on `Super+Space` and `wdisplays` on `Super+P`. The ThinkPad's star-marked user-defined key controls media: star toggles play/pause, `Shift+Star` skips forward, and `Alt+Shift+Star` goes to the previous track. Sway's personal overrides live in `linux/.config/sway/config.d/`: `Super+H/J/K/L` focuses, `Super+Shift+H/J/K/L` moves windows, `Super+1…9/0` switches workspaces, `Super+Shift+1…9/0` moves and follows windows, `Super+T` toggles floating, `Super+W` closes, `Super+Return` opens WezTerm, `Super+P` opens display controls, `Super+Shift+S` captures an area and copies it to the clipboard, and `Super+Escape` locks.

Privileged Fedora configuration lives under `fedora/etc/`; rerun `./fedora-install.sh` after changing it. The tracked sudo PAM policy makes terminal `sudo` use Fedora's password-only authentication stack.

Check or temporarily disable the Kanata remapper with:

```bash
sudo systemctl status kanata
sudo systemctl disable --now kanata
```
