#!/usr/bin/env bash

set -euo pipefail

readonly WEZTERM_COPR="wezfurlong/wezterm-nightly"
readonly NERD_FONTS_VERSION="v3.5.1"
readonly KANATA_VERSION="1.11.0"
readonly KANATA_ARCHIVE_SHA256="d9f634afb4c7f078cc2aacf3998fd65b432d4d83296cc48a89f941525459b4e2"
readonly KANATA_ARCHIVE_URL="https://github.com/jtroo/kanata/releases/download/v${KANATA_VERSION}/linux-binaries-x64.zip"
REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT
readonly P10K_DIR="$HOME/.local/share/powerlevel10k"
readonly FONT_DIR="$HOME/.local/share/fonts/HackNerdFont"
readonly TPM_DIR="$HOME/.config/tmux/plugins/tpm"
readonly -a FEDORA_PACKAGES=(
	blueman
	brightnessctl
	curl
	direnv
	dnf5-plugins
	dunst
	eza
	fd-find
	fuzzel
	fontconfig
	grimshot
	fzf
	git
	gnome-extensions-app
	gnome-shell-extension-appindicator
	gnome-shell-extension-pop-shell
	gnome-shell-extension-pop-shell-shortcut-overrides
	gtklock
	ImageMagick
	jq
	network-manager-applet
	neovim
	pavucontrol
	playerctl
	stow
	sway
	sway-config-fedora
	swaybg
	swayidle
	swaylock
	tmux
	unzip
	waybar
	wdisplays
	wl-clipboard
	xdg-desktop-portal-gtk
	xdg-desktop-portal-wlr
	xorg-x11-server-Xwayland
	xz
	zoxide
	zsh
)
log() {
	printf '\n==> %s\n' "$1"
}

if ! command -v dnf >/dev/null 2>&1; then
	echo "This installer supports Fedora systems with dnf." >&2
	exit 1
fi

if [[ ! -r /etc/os-release ]] || ! grep -q '^ID=fedora$' /etc/os-release; then
	echo "This installer supports Fedora only." >&2
	exit 1
fi

missing_packages=()
for package in "${FEDORA_PACKAGES[@]}"; do
	if ! rpm -q "$package" >/dev/null 2>&1; then
		missing_packages+=("$package")
	fi
done

if ((${#missing_packages[@]} > 0)); then
	log "Installing missing Fedora workstation packages"
	sudo dnf install -y "${missing_packages[@]}"
else
	log "Fedora workstation packages are already installed"
fi

if ! command -v wezterm >/dev/null 2>&1; then
	log "Enabling the official WezTerm nightly COPR"
	sudo dnf copr enable -y "$WEZTERM_COPR"
	sudo dnf install -y wezterm
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
	echo "The pinned Kanata binary currently supports x86_64 Fedora only." >&2
	exit 1
fi

if ! /usr/local/bin/kanata --version 2>/dev/null | grep -q "${KANATA_VERSION}"; then
	log "Installing Kanata ${KANATA_VERSION}"
	tmp_dir="$(mktemp -d)"
	trap 'rm -rf "$tmp_dir"' EXIT
	curl --fail --location --output "$tmp_dir/kanata.zip" "$KANATA_ARCHIVE_URL"
	echo "$KANATA_ARCHIVE_SHA256  $tmp_dir/kanata.zip" | sha256sum --check --status
	unzip -q "$tmp_dir/kanata.zip" kanata_linux_x64 -d "$tmp_dir"
	sudo install -Dm0755 "$tmp_dir/kanata_linux_x64" /usr/local/bin/kanata
	rm -rf "$tmp_dir"
	trap - EXIT
fi

log "Installing the system-wide Kanata configuration"
/usr/local/bin/kanata --cfg "$REPO_ROOT/fedora/etc/kanata/kanata.kbd" --check
sudo install -Dm0644 "$REPO_ROOT/fedora/etc/kanata/kanata.kbd" /etc/kanata/kanata.kbd
sudo install -Dm0644 "$REPO_ROOT/fedora/etc/modules-load.d/kanata.conf" /etc/modules-load.d/kanata.conf
sudo install -Dm0644 "$REPO_ROOT/fedora/etc/systemd/system/kanata.service" /etc/systemd/system/kanata.service

log "Configuring password-only authentication for sudo"
sudo install -Dm0644 "$REPO_ROOT/fedora/etc/pam.d/sudo" /etc/pam.d/sudo

sudo modprobe uinput
sudo systemctl daemon-reload
sudo systemctl enable --now kanata.service

if [[ ! -d "$P10K_DIR/.git" ]]; then
	log "Installing Powerlevel10k in user space"
	mkdir -p "$(dirname -- "$P10K_DIR")"
	git clone --depth 1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

if ! fc-match 'Hack Nerd Font Mono' | grep -qi 'HackNerdFontMono'; then
	log "Installing Hack Nerd Font $NERD_FONTS_VERSION in user space"
	tmp_dir="$(mktemp -d)"
	trap 'rm -rf "$tmp_dir"' EXIT
	curl --fail --location --output "$tmp_dir/Hack.tar.xz" \
		"https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONTS_VERSION/Hack.tar.xz"
	mkdir -p "$FONT_DIR"
	tar -xJf "$tmp_dir/Hack.tar.xz" -C "$FONT_DIR"
	fc-cache -f "$FONT_DIR"
	rm -rf "$tmp_dir"
	trap - EXIT
fi

log "Stowing the shared and Linux configuration"
# Earlier setup iterations created managed links for the retired X11/i3 stack.
# Remove only links owned by this checkout; never delete personal local config.
for relative_path in \
	.Xresources \
	.xprofile \
	.config/autorandr \
	.config/i3 \
	.config/i3status \
	.config/omarchy \
	.config/picom \
	.config/polybar \
	.config/rofi \
	.config/theme \
	.config/ulauncher \
	.config/walker \
	.config/wofi \
	.config/xdg-desktop-portal/i3-portals.conf \
	.local/bin/flameshot-x11 \
	.local/bin/i3bar-polybar-fallback \
	.local/bin/i3-display-watch \
	.local/bin/i3-lock-background-refresh \
	.local/bin/i3-lock-safe \
	.local/bin/i3-osd \
	.local/bin/i3-screenshot \
	.local/bin/i3-system-action \
	.local/bin/i3-wallpaper-restore \
	.local/bin/polybar-launch \
	.local/bin/rofi-launcher \
	.local/bin/theme-apply; do
	target="$HOME/$relative_path"
	if [[ -L "$target" && "$(realpath -m -- "$target")" == "$REPO_ROOT/linux/"* ]]; then
		rm -- "$target"
	fi
done
for relative_path in \
	.local/share/applications/org.flameshot.Flameshot.desktop \
	.local/share/applications/power-lock.desktop \
	.local/share/applications/power-logout.desktop \
	.local/share/applications/power-restart.desktop \
	.local/share/applications/power-shutdown.desktop \
	.local/share/applications/power-suspend.desktop; do
	target="$HOME/$relative_path"
	if [[ -L "$target" && "$(realpath -m -- "$target")" == "$REPO_ROOT/linux/"* ]]; then
		rm -- "$target"
	fi
done
for relative_path in .config/dunst; do
	target="$HOME/$relative_path"
	expected="$REPO_ROOT/linux/$relative_path"
	if [[ -L "$target" && "$(readlink -f -- "$target")" == "$(readlink -f -- "$expected")" ]]; then
		rm -- "$target"
	fi
done
stow --dir="$REPO_ROOT" --target="$HOME" --restow common linux
"$HOME/.local/bin/palette-apply"

if [[ -r "$HOME/Pictures/wallpapers/wallpaper_icy.jpg" ]]; then
	log "Preparing the blurred Sway lock background"
	"$HOME/.local/bin/sway-lock-background-refresh"
fi

if [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]]; then
	log "Configuring GNOME and the parallel Sway session"
	"$REPO_ROOT/fedora/configure-gnome.sh"
else
	log "GNOME configuration deferred; run fedora/configure-gnome.sh once from a GNOME session"
fi

systemctl --user daemon-reload

if [[ ! -d "$TPM_DIR/.git" ]]; then
	log "Installing Tmux Plugin Manager"
	git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

log "Installing tmux plugins"
"$TPM_DIR/bin/install_plugins"

/usr/bin/zsh -n "$HOME/.zshrc"
wezterm --config-file "$HOME/.wezterm.lua" show-keys --lua >/dev/null

tmux -L dotfiles-install-test -f "$HOME/.config/tmux/tmux.conf" new-session -d -s dotfiles-install-test
tmux -L dotfiles-install-test kill-server

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "/usr/bin/zsh" ]]; then
	log "Changing the login shell to Zsh"
	chsh -s /usr/bin/zsh
fi

cat <<'EOF'

Fedora setup complete.

- Open a new terminal or sign out and back in to start Zsh.
- Open Neovim normally and let vim.pack/Mason finish their own setup.
- Kanata remaps Caps Lock to Escape when tapped and Control when held.
- Terminal sudo uses the account password.
- Sway is the lightweight tiling session; GNOME remains available from GDM's gear menu.
- Choose Sway or GNOME from GDM's gear menu before signing in.
- If this installer ran outside GNOME, run fedora/configure-gnome.sh once from a GNOME session.
EOF
