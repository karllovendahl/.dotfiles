#!/usr/bin/env bash

set -euo pipefail

readonly -a RETIRED_X11_PACKAGES=(
	arandr
	dmenu
	dex-autostart
	feh
	i3
	i3-config-fedora
	i3lock
	i3status
	i3status-config
	maim
	picom
	polybar
	rofi
	rofi-themes
	slop
	ulauncher
	xclip
	xorg-x11-server-Xorg
	xrandr
	xset
	xss-lock
)

if [[ "${1:-}" != "--confirm" || $# -ne 1 ]]; then
	cat >&2 <<'EOF'
Usage: ./fedora-retire-i3.sh --confirm

Removes the retired i3/Xorg desktop stack and its X11-only tools. It retains
Sway, GNOME Wayland, and XWayland for individual X11 applications.
EOF
	exit 2
fi

if ! command -v dnf >/dev/null 2>&1 || ! grep -q '^ID=fedora$' /etc/os-release; then
	echo "This migration supports Fedora only." >&2
	exit 1
fi

installed_packages=()
for package in "${RETIRED_X11_PACKAGES[@]}"; do
	if rpm -q "$package" >/dev/null 2>&1; then
		installed_packages+=("$package")
	fi
done

if ((${#installed_packages[@]} > 0)); then
	printf 'Removing retired X11/i3 packages: %s\n' "${installed_packages[*]}"
	sudo dnf remove -y "${installed_packages[@]}"
else
	printf '%s\n' 'The retired X11/i3 packages are already absent.'
fi

# This was installed by the former i3/Xorg profile, not by Fedora itself.
sudo rm -f /etc/X11/xorg.conf.d/30-touchpad.conf
