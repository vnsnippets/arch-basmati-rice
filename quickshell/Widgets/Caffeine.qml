import QtQuick

import Quickshell
import Quickshell.Io

import qs
import qs.Utilities
import qs.Services

WidgetBase {
    id: widget

    property var state: StateProvider.caffeine_widget
    readonly property bool active: state.prevent_lock_process !== null

    // (Active: True)   - Caffeine active (System won't lock)
    // (Active: False)  - Auto-lock is active (System will lock)
    icon: (active) ? "" : ""
    label: (active) ? `[${state.prevent_lock_process.processId}]` : ""
    style.foreground.idle: (active) ? Theme.color_red : Theme.color_green
    
    onClicked: () => {
        if (active) {
            state.prevent_lock_process.running = false;
            state.prevent_lock_process = null;
        } else {
            // Start and save the reference
            var cmd = ["systemd-inhibit", "--what=idle", "sleep", "infinity"]
            state.prevent_lock_process = Daemon.execute(cmd);

            // Process dies unexpectedly (crashes), reset our state
            state.prevent_lock_process.runningChanged.connect(() => {
                if (state.prevent_lock_process && !state.prevent_lock_process.running) {
                    state.prevent_lock_process.running = false;
                    state.prevent_lock_process = null;
                }
            });
        }
    }
}