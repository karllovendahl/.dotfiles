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

if [[ "$(uname -m)" != "x86_64" ]]; then
	echo "The pinned Kanata binary currently supports x86_64 Fedora only." >&2
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

link_resolves_under() {
	local target="$1" source_root="$2" link_source
	[[ -L "$target" ]] || return 1
	link_source="$(readlink -- "$target")"
	[[ "$link_source" == /* ]] || link_source="$(dirname -- "$target")/$link_source"
	link_source="$(realpath -ms -- "$link_source")"
	[[ "$link_source" == "$source_root/"* ]]
}

legacy_linux_link() {
	link_resolves_under "$1" "$REPO_ROOT/linux"
}

migrate_legacy_linux_links() {
	local package="$1" migration_dir manifest archive profile_manifest profile_archive target relative
	migration_dir="$(mktemp -d)"
	manifest="$migration_dir/legacy-links"
	archive="$migration_dir/legacy-links.tar"
	profile_manifest="$migration_dir/profile-links"
	profile_archive="$migration_dir/profile-links.tar"

	for root in "$HOME/.config" "$HOME/.local" "$HOME/.Xresources" "$HOME/.xprofile"; do
		[[ -e "$root" || -L "$root" ]] || continue
		while IFS= read -r -d '' target; do
			if legacy_linux_link "$target"; then
				relative=".${target#"$HOME"}"
				printf '%s\0' "$relative" >>"$manifest"
			fi
		done < <(find -P "$root" -maxdepth 6 -type l -print0)
	done

	if [[ ! -s "$manifest" ]]; then
		stow --simulate --dir="$REPO_ROOT" --target="$HOME" --restow "$package"
		stow --dir="$REPO_ROOT" --target="$HOME" --restow "$package"
		rm -rf "$migration_dir"
		return 0
	fi
	(
		cd "$HOME"
		tar --null --files-from="$manifest" --create --file="$archive"
	)

	archive_profile_links() {
		for root in "$HOME/.config" "$HOME/.local" "$HOME/.Xresources" "$HOME/.xprofile"; do
			[[ -e "$root" || -L "$root" ]] || continue
			while IFS= read -r -d '' target; do
				if link_resolves_under "$target" "$REPO_ROOT/$package"; then
					relative=".${target#"$HOME"}"
					printf '%s\0' "$relative" >>"$profile_manifest"
				fi
			done < <(find -P "$root" -maxdepth 6 -type l -print0)
		done
		[[ -s "$profile_manifest" ]] || return 0
		(
			cd "$HOME"
			tar --null --files-from="$profile_manifest" --create --file="$profile_archive"
		)
	}

	remove_profile_links() {
		local current_profile_links="$migration_dir/current-profile-links"
		: >"$current_profile_links"
		for root in "$HOME/.config" "$HOME/.local" "$HOME/.Xresources" "$HOME/.xprofile"; do
			[[ -e "$root" || -L "$root" ]] || continue
			while IFS= read -r -d '' target; do
				if link_resolves_under "$target" "$REPO_ROOT/$package"; then
					printf '%s\0' "$target" >>"$current_profile_links"
				fi
			done < <(find -P "$root" -maxdepth 6 -type l -print0)
		done
		while IFS= read -r -d '' target; do rm -- "$target"; done <"$current_profile_links"
	}

	restore_legacy_links() {
		while IFS= read -r -d '' relative; do rm -f -- "$HOME/${relative#.}"; done <"$manifest"
		(
			cd "$HOME"
			tar --extract --file="$archive"
		)
		echo "Legacy Linux links restored after migration failed." >&2
	}

	restore_profile_links() {
		remove_profile_links
		[[ -s "$profile_manifest" ]] || return 0
		(
			cd "$HOME"
			tar --extract --file="$profile_archive"
		)
	}

	remove_legacy_links() {
		local removal_failed=0
		while IFS= read -r -d '' relative; do
			rm -- "$HOME/${relative#.}" || removal_failed=1
		done <"$manifest"
		return "$removal_failed"
	}

	archive_profile_links
	if ! remove_legacy_links ||
		! stow --simulate --dir="$REPO_ROOT" --target="$HOME" --restow "$package"; then
		restore_legacy_links
		rm -rf "$migration_dir"
		return 1
	fi
	if ! stow --dir="$REPO_ROOT" --target="$HOME" --restow "$package"; then
		restore_profile_links || true
		restore_legacy_links || true
		rm -rf "$migration_dir"
		return 1
	fi
	rm -rf "$migration_dir"
}

log "Stowing the shared configuration"
stow --dir="$REPO_ROOT" --target="$HOME" --restow common
log "Migrating legacy Linux links and stowing Fedora configuration"
migrate_legacy_linux_links fedora-home
"$HOME/.local/bin/palette-apply" --fedora

if [[ -r "$HOME/Pictures/wallpapers/wallpaper_icy.jpg" ]]; then
	log "Preparing the blurred Sway lock background"
	"$HOME/.local/bin/sway-lock-background-refresh"
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
- Sway is the primary session; stock GNOME remains available from GDM's gear menu.
- Choose Sway or GNOME from GDM's gear menu before signing in.
EOF
