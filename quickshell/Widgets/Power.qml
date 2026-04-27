import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities

Base {
    id: widget
    icon: ""

    onClicked: () => {
        var cmd = ["pkill", "-9", "quickshell"]
        Context.process.shutdown = Daemon.execute(cmd);
    }
}