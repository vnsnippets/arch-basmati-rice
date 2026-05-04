import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.Utilities
import qs.Types.Components

ClickableWithIconAndLabel {
    id: widget
    icon: ""

    onClicked: () => {
        var cmd = ["poweroff"]
        Context.process.shutdown = Daemon.execute(cmd);
    }
}