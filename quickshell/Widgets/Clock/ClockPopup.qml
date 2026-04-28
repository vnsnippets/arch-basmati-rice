import QtQuick
import QtQuick.Layouts

import Quickshell

import qs
import qs.Styles
import qs.Widgets

Popup {
    id: root
    ColumnLayout {
        anchors.centerIn: parent
        Text {
            text: "Hello World from clock"
            color: DefaultStyle.color_light
            font.family: DefaultStyle.fonts.family
            font.pixelSize: DefaultStyle.fonts.size
        }
    }
}