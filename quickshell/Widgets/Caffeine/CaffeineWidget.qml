import QtQuick

import Quickshell
import Quickshell.Io

import qs
import qs.Styles
import qs.Controls
import qs.Utilities

Clickable {
    id: root

    readonly property bool active: Context.process.prevent_screen_lock !== null

    property color color_caffeineon: Style.colors.red
    property color color_caffeineoff: Style.colors.text
    
    onClicked: () => {
        if (active) {
            Context.process.prevent_screen_lock.running = false;
            Context.process.prevent_screen_lock = null;
        } else {
            // Start and save the reference
            var cmd = ["systemd-inhibit", "--what=idle", "sleep", "infinity"]
            Context.process.prevent_screen_lock = Daemon.execute(cmd);

            // Process dies unexpectedly (crashes), reset our state
            Context.process.prevent_screen_lock.runningChanged.connect(() => {
                if (Context.process.prevent_screen_lock && !Context.process.prevent_screen_lock.running) {
                    Context.process.prevent_screen_lock.running = false;
                    Context.process.prevent_screen_lock = null;
                }
            });
        }
    }

    StyledText {
        anchors.centerIn: parent
        text: (root.active) ? "󱂟" : ""
        color: (root.active) ? root.color_caffeineon : root.color_caffeineoff
    }
}