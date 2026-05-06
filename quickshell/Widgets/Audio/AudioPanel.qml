pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs
import qs.Styles
import qs.Controls
import qs.Utilities
import qs.Widgets.Battery.Controls

ColumnLayout {
    id: container
    anchors.centerIn: parent
    spacing: Style.panel.spacing
    
    Text {
        color: "white"
        text: "Hello World"
    }
}