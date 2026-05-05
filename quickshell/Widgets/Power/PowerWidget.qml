import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Controls
import qs.Utilities

ClickableWithLabel {
    id: widget
    icon: ""

    onClicked: () => {
        var cmd = ["poweroff"]
        Context.process.shutdown = Daemon.execute(cmd);
    }
}