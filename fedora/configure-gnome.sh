#!/usr/bin/env bash

set -euo pipefail

readonly GSETTINGS="/usr/bin/gsettings"
readonly GNOME_EXTENSIONS="/usr/bin/gnome-extensions"
readonly POP_SHELL_SCHEMA="org.gnome.shell.extensions.pop-shell"
readonly RETIRED_ULAUNCHER_KEYBINDING_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ulauncher/"

if [[ "${XDG_CURRENT_DESKTOP:-}" != *GNOME* ]]; then
	echo "Skipping GNOME configuration outside a GNOME session."
	exit 0
fi

shopt -s nullglob
pop_shell_dirs=(/usr/share/gnome-shell/extensions/*pop-shell*)
if ((${#pop_shell_dirs[@]} != 1)) || ! "$GSETTINGS" writable "$POP_SHELL_SCHEMA" tile-by-default >/dev/null 2>&1; then
	echo "Pop Shell is unavailable; install gnome-shell-extension-pop-shell first." >&2
	exit 1
fi
readonly POP_SHELL_UUID="${pop_shell_dirs[0]##*/}"
appindicator_dirs=(/usr/share/gnome-shell/extensions/*appindicator*)
if ((${#appindicator_dirs[@]} != 1)); then
	echo "AppIndicator support is unavailable; install gnome-shell-extension-appindicator first." >&2
	exit 1
fi
readonly APPINDICATOR_UUID="${appindicator_dirs[0]##*/}"
readonly PANEL_EXTENSION_UUID="numbered-workspaces@dotfiles"
readonly PANEL_EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$PANEL_EXTENSION_UUID"
if [[ ! -d "$PANEL_EXTENSION_DIR" ]]; then
	echo "Numbered workspace extension is unavailable; stow the Linux dotfiles first." >&2
	exit 1
fi

# Keep GNOME as the desktop while approximating Hyprland's per-monitor model:
# dynamic workspaces live on the primary monitor, while windows on secondary
# monitors remain visible when switching. GNOME keeps one empty workspace ready.
"$GSETTINGS" set org.gnome.mutter dynamic-workspaces true
"$GSETTINGS" set org.gnome.mutter workspaces-only-on-primary true
"$GSETTINGS" set org.gnome.mutter overlay-key ''
"$GSETTINGS" set org.gnome.desktop.interface enable-animations false
"$GSETTINGS" set org.gnome.desktop.interface enable-hot-corners false

# Keep Omarchy's 40 Hz repeat rate but use a faster 140 ms initial delay.
# GNOME stores the repeat period in milliseconds, so 40 Hz becomes 25 ms.
"$GSETTINGS" set org.gnome.desktop.peripherals.keyboard repeat true
"$GSETTINGS" set org.gnome.desktop.peripherals.keyboard delay 140
"$GSETTINGS" set org.gnome.desktop.peripherals.keyboard repeat-interval 25

# GNOME reserves Super+1…9 for pinned applications by default. Clear those
# bindings before assigning the same keys to existing dynamic workspaces.
for slot in {1..9}; do
	"$GSETTINGS" set org.gnome.shell.keybindings "switch-to-application-${slot}" '[]'
	"$GSETTINGS" set org.gnome.desktop.wm.keybindings "switch-to-workspace-${slot}" "['<Super>${slot}']"
	"$GSETTINGS" set org.gnome.desktop.wm.keybindings "move-to-workspace-${slot}" "['<Super><Shift>${slot}']"
done

"$GSETTINGS" set org.gnome.desktop.wm.keybindings switch-to-workspace-10 "['<Super>0']"
"$GSETTINGS" set org.gnome.desktop.wm.keybindings move-to-workspace-10 "['<Super><Shift>0']"
"$GSETTINGS" set org.gnome.desktop.wm.keybindings close "['<Alt>F4', '<Super>w']"

# Super+Space normally switches input sources. Keep the hardware keyboard key
# available for that job and use Super+Space for GNOME's normal application grid.
"$GSETTINGS" set org.gnome.desktop.wm.keybindings switch-input-source "['XF86Keyboard']"
"$GSETTINGS" set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift>XF86Keyboard']"
"$GSETTINGS" set org.gnome.shell.keybindings toggle-application-view "['<Super>space']"
custom_keybindings="$($GSETTINGS get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)"
custom_keybindings="$(CUSTOM_KEYBINDINGS="$custom_keybindings" RETIRED_PATH="$RETIRED_ULAUNCHER_KEYBINDING_PATH" /usr/bin/python3 - <<'PY'
import ast
import os

bindings = ast.literal_eval(os.environ["CUSTOM_KEYBINDINGS"])
retired = os.environ["RETIRED_PATH"]
print(repr([binding for binding in bindings if binding != retired]))
PY
)"
"$GSETTINGS" set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$custom_keybindings"

# The ThinkPad's star-marked user-defined key emits XF86Favorites. Turn it into
# a compact media cluster without taking the standard F12 key.
"$GSETTINGS" set org.gnome.settings-daemon.plugins.media-keys play "['XF86Favorites']"
"$GSETTINGS" set org.gnome.settings-daemon.plugins.media-keys next "['<Shift>XF86Favorites']"
"$GSETTINGS" set org.gnome.settings-daemon.plugins.media-keys previous "['<Alt><Shift>XF86Favorites']"

# Pop Shell adds automatic tree-based tiling to GNOME. Keep the per-window
# floating toggle and movement controls aligned with the Sway muscle memory.
"$GSETTINGS" set "$POP_SHELL_SCHEMA" tile-by-default true
"$GSETTINGS" set "$POP_SHELL_SCHEMA" toggle-floating "['<Super>t']"
"$GSETTINGS" set "$POP_SHELL_SCHEMA" tile-orientation '[]'
"$GSETTINGS" set "$POP_SHELL_SCHEMA" mouse-cursor-follows-active-window true
"$GSETTINGS" set "$POP_SHELL_SCHEMA" mouse-cursor-focus-location 4
"$GSETTINGS" set "$POP_SHELL_SCHEMA" tile-move-left-global "['<Super><Shift>h']"
"$GSETTINGS" set "$POP_SHELL_SCHEMA" tile-move-down-global "['<Super><Shift>j']"
"$GSETTINGS" set "$POP_SHELL_SCHEMA" tile-move-up-global "['<Super><Shift>k']"
"$GSETTINGS" set "$POP_SHELL_SCHEMA" tile-move-right-global "['<Super><Shift>l']"

if "$GNOME_EXTENSIONS" enable "$POP_SHELL_UUID" 2>/dev/null; then
	echo "Pop Shell enabled."
else
	# GNOME does not discover newly installed system extensions until the next
	# Wayland login. Add it to the enabled set now so that login activates it.
	enabled_extensions="$("$GSETTINGS" get org.gnome.shell enabled-extensions)"
	enabled_extensions="$(ENABLED_EXTENSIONS="$enabled_extensions" EXTENSION_UUID="$POP_SHELL_UUID" /usr/bin/python3 - <<'PY'
import ast
import os

enabled = ast.literal_eval(os.environ["ENABLED_EXTENSIONS"])
uuid = os.environ["EXTENSION_UUID"]
if uuid not in enabled:
    enabled.append(uuid)
print(repr(enabled))
PY
)"
	"$GSETTINGS" set org.gnome.shell enabled-extensions "$enabled_extensions"
	echo "Pop Shell will activate at the next GNOME login."
fi

if "$GNOME_EXTENSIONS" enable "$APPINDICATOR_UUID" 2>/dev/null; then
	echo "AppIndicator tray support enabled."
else
	echo "AppIndicator support is installed; sign out and back in, then enable it in Extensions if needed."
fi

if "$GNOME_EXTENSIONS" enable "$PANEL_EXTENSION_UUID" 2>/dev/null; then
	echo "Numbered workspace panel enabled."
else
	enabled_extensions="$("$GSETTINGS" get org.gnome.shell enabled-extensions)"
	enabled_extensions="$(ENABLED_EXTENSIONS="$enabled_extensions" EXTENSION_UUID="$PANEL_EXTENSION_UUID" /usr/bin/python3 - <<'PY'
import ast
import os

enabled = ast.literal_eval(os.environ["ENABLED_EXTENSIONS"])
uuid = os.environ["EXTENSION_UUID"]
if uuid not in enabled:
    enabled.append(uuid)
print(repr(enabled))
PY
)"
	"$GSETTINGS" set org.gnome.shell enabled-extensions "$enabled_extensions"
	echo "Numbered workspace panel will activate at the next GNOME login."
fi

echo "GNOME: animations off; primary-only dynamic workspaces; clock left; numbered workspaces centered."
echo "Shortcuts: Super+1…9/0 switches; Super+Space opens GNOME apps."
echo "Pop Shell: Super+T toggles floating; Super+Shift+H/J/K/L moves tiled windows; Super+W closes."
echo "Sway remains available as an optional session from GDM's login-screen gear menu."
