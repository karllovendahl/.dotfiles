import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import St from 'gi://St';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

export default class NumberedWorkspacesExtension extends Extension {
    enable() {
        this._workspaceManager = global.workspace_manager;
        this._lastPrimaryWindowByWorkspace = new Map();
        this._focusTimeout = 0;
        this._focusSignal = global.display.connect(
            'notify::focus-window',
            () => this._rememberPrimaryFocus());
        this._rememberPrimaryFocus();
        this._installNotificationTimeout();

        this._dateMenu = Main.panel.statusArea.dateMenu.container;
        this._dateMenuParent = this._dateMenu.get_parent();
        this._dateMenuIndex = this._dateMenuParent
            .get_children()
            .indexOf(this._dateMenu);

        this._dateMenuParent.remove_child(this._dateMenu);
        Main.panel._leftBox.insert_child_at_index(this._dateMenu, 0);

        this._workspaceBox = new St.BoxLayout({
            style_class: 'numbered-workspaces',
            y_align: Clutter.ActorAlign.CENTER,
        });
        Main.panel._centerBox.add_child(this._workspaceBox);

        this._workspaceSignals = [
            this._workspaceManager.connect(
                'notify::n-workspaces',
                () => this._rebuild()),
            this._workspaceManager.connect(
                'active-workspace-changed',
                () => this._onWorkspaceChanged()),
        ];

        this._rebuild();
    }

    disable() {
        for (const signal of this._workspaceSignals ?? [])
            this._workspaceManager.disconnect(signal);
        this._workspaceSignals = null;

        if (this._focusSignal)
            global.display.disconnect(this._focusSignal);
        this._focusSignal = 0;
        if (this._focusTimeout)
            GLib.source_remove(this._focusTimeout);
        this._focusTimeout = 0;
        this._lastPrimaryWindowByWorkspace = null;
        this._removeNotificationTimeout();

        this._workspaceBox?.destroy();
        this._workspaceBox = null;

        if (this._dateMenu?.get_parent())
            this._dateMenu.get_parent().remove_child(this._dateMenu);
        if (this._dateMenuParent)
            this._dateMenuParent.insert_child_at_index(
                this._dateMenu,
                this._dateMenuIndex);

        this._dateMenu = null;
        this._dateMenuParent = null;
        this._workspaceManager = null;
    }

    _rebuild() {
        this._workspaceBox.destroy_all_children();

        for (let index = 0;
            index < this._workspaceManager.n_workspaces;
            index++) {
            const button = new St.Button({
                label: `${index + 1}`,
                style_class: 'numbered-workspace-button',
                can_focus: true,
                reactive: true,
                track_hover: true,
            });
            button.workspaceIndex = index;
            button.connect('clicked', () => {
                this._workspaceManager
                    .get_workspace_by_index(index)
                    .activate(global.get_current_time());
            });
            this._workspaceBox.add_child(button);
        }

        this._updateActive();
    }

    _installNotificationTimeout() {
        this._bannerTimeout = 0;
        this._messageTray = Main.messageTray;
        this._originalShowNotificationCompleted =
            this._messageTray._showNotificationCompleted;

        const extension = this;
        this._patchedShowNotificationCompleted = function () {
            extension._originalShowNotificationCompleted.call(this);
            extension._scheduleBannerTimeout(this);
        };
        this._messageTray._showNotificationCompleted =
            this._patchedShowNotificationCompleted;
    }

    _scheduleBannerTimeout(messageTray) {
        if (this._bannerTimeout)
            GLib.source_remove(this._bannerTimeout);

        const notification = messageTray._notification;
        this._bannerTimeout = GLib.timeout_add_once(
            GLib.PRIORITY_DEFAULT,
            5000,
            () => {
                this._bannerTimeout = 0;
                if (messageTray._notification !== notification)
                    return;

                messageTray._pointerInNotification = false;
                messageTray._expireNotification();
            });
    }

    _removeNotificationTimeout() {
        if (this._bannerTimeout)
            GLib.source_remove(this._bannerTimeout);
        this._bannerTimeout = 0;

        if (this._messageTray?._showNotificationCompleted ===
            this._patchedShowNotificationCompleted) {
            this._messageTray._showNotificationCompleted =
                this._originalShowNotificationCompleted;
        }

        this._messageTray = null;
        this._patchedShowNotificationCompleted = null;
        this._originalShowNotificationCompleted = null;
    }

    _rememberPrimaryFocus() {
        const window = global.display.focus_window;
        if (!window || window.get_monitor() !== Main.layoutManager.primaryIndex)
            return;

        const workspace = window.get_workspace();
        if (workspace)
            this._lastPrimaryWindowByWorkspace.set(workspace.index(), window);
    }

    _onWorkspaceChanged() {
        this._updateActive();

        if (this._focusTimeout)
            GLib.source_remove(this._focusTimeout);
        this._focusTimeout = GLib.timeout_add(
            GLib.PRIORITY_DEFAULT,
            50,
            () => {
                this._focusTimeout = 0;
                this._focusPrimaryWindow();
                return GLib.SOURCE_REMOVE;
            });
    }

    _focusPrimaryWindow() {
        const workspace = this._workspaceManager.get_active_workspace();
        const primaryIndex = Main.layoutManager.primaryIndex;
        const focused = global.display.focus_window;
        if (focused?.get_monitor() === primaryIndex &&
            focused.get_workspace() === workspace)
            return;

        const windows = workspace.list_windows().filter(window =>
            window.get_monitor() === primaryIndex &&
            !window.minimized &&
            !window.skip_taskbar);

        if (windows.length === 0)
            return;

        const workspaceIndex = workspace.index();
        let target = this._lastPrimaryWindowByWorkspace.get(workspaceIndex);
        if (!windows.includes(target)) {
            const windowSet = new Set(windows);
            target = global.get_window_actors()
                .map(actor => actor.meta_window)
                .reverse()
                .find(window => windowSet.has(window));
        }

        if (target)
            workspace.activate_with_focus(target, global.get_current_time());
    }

    _updateActive() {
        const activeIndex = this._workspaceManager
            .get_active_workspace_index();

        for (const button of this._workspaceBox.get_children()) {
            if (button.workspaceIndex === activeIndex)
                button.add_style_pseudo_class('active');
            else
                button.remove_style_pseudo_class('active');
        }
    }
}
