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

    property color backgroundIdleColor: Style.colors.base
    property color backgroundActiveColor: Style.colors.mantle

    property color borderIdleColor: backgroundIdleColor
    property color borderActiveColor: Style.colors.text

    implicitWidth: Math.max(container.childrenRect.width + Style.clickable.padding, Style.clickable.width)
    height: Style.clickable.height

    Layout.alignment: Qt.AlignCenter
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    
    Rectangle {
        id: container
        anchors.left: parent.left
        scale: 1.0

        height: parent.height // Follow root height

        color: root.containsMouse ? root.backgroundActiveColor : root.backgroundIdleColor
        border.color: root.containsMouse ? root.borderActiveColor : root.borderIdleColor
        border.width: Style.clickable.borderWidth

        radius: root.radius
        clip: true
        // antialiasing: true

        Behavior on scale { NumberAnimation { duration: Style.animations.duration/2; } }
        Behavior on radius { NumberAnimation { duration: Style.animations.duration/2; } }
        Behavior on color { ColorAnimation { duration: Style.animations.duration/2; } }
        Behavior on border.color { ColorAnimation { duration: Style.animations.duration/2; } }
    }
}