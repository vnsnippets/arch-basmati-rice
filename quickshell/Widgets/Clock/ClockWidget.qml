import QtQuick
import Quickshell

import qs
import qs.Styles
import qs.Controls
import qs.Utilities

ClickableWithLabel {
    id: root
    property string format: "yyyy-MM-dd HH:mm"

    SystemClock {
        id: system_clock
        precision: SystemClock.Minutes
    }

    label: Qt.formatDateTime(system_clock.date, format)
}