import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities

Base {
    id: widget
    icon: ""

    // Style: Idle
    style.text.idle: Theme.color_red

    // Style: Active
    style.background.active: Theme.color_red
    style.text.active: Theme.color_dark
    style.border.active: Theme.color_red

    onClicked: () => {
        var cmd = ["poweroff"]
        Global.process.shutdown = Daemon.execute(cmd);
    }
}