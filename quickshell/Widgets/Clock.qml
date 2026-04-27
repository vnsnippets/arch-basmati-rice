import QtQuick
import Quickshell

import qs
import qs.Styles
import qs.Utilities

Base {
    id: w_clock
    objectName: "w_clock"

    property string format: "yyyy-MM-dd HH:mm"

    SystemClock {
        id: system_clock
        precision: SystemClock.Minutes
    }

    label: Qt.formatDateTime(system_clock.date, format)

    Component {
        id: w_popup

        Text {
            id: popup_text
            text: "Hello World"
            color: DefaultStyle.color_light
            font.family: DefaultStyle.fonts.family
            font.pixelSize: DefaultStyle.fonts.size
            anchors.centerIn: parent
        }
    }

    onClicked: panel_group.delegateWidgetPopup(this, w_popup);
}