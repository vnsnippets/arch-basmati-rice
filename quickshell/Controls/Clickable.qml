pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

import qs
import qs.Types
import qs.Styles
import qs.Utilities

WrapperMouseArea {
    id: root

    default property alias contentData: container.data

    property int radius: Style.clickable.radius

    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property color backgroundIdleColor: Style.clickable.background.idle
    property color backgroundActiveColor: Style.clickable.background.active

    property color borderIdleColor: Style.clickable.border.idle
    property color borderActiveColor: Style.clickable.border.active

    implicitWidth: Style.clickable.width
    height: Style.clickable.height

    Layout.alignment: Qt.AlignCenter
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        id: container
        anchors.left: parent.left
        scale: 1.0

        height: parent.height
        
        color: root.containsMouse ? root.backgroundActiveColor : root.backgroundIdleColor
        border.color: root.containsMouse ? root.borderActiveColor : root.borderIdleColor
        border.width: Style.borderWidth

        radius: root.radius
        clip: true
        // antialiasing: true

        Behavior on scale { NumberAnimation { duration: Style.animations.duration/2; } }
        Behavior on radius { NumberAnimation { duration: Style.animations.duration/2; } }
        Behavior on color { ColorAnimation { duration: Style.animations.duration/2; } }
        Behavior on border.color { ColorAnimation { duration: Style.animations.duration/2; } }
    }
}