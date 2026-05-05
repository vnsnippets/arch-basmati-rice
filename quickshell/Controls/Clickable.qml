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

    property int radius: style.radius

    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property ClickableStyle style: ClickableStyle {}
    
    width: implicitWidth
    implicitWidth: container.childrenRect.width + Style.widget.padding
    implicitHeight: Style.widget.height

    Layout.alignment: Qt.AlignCenter
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onPressed: root.state = ClickableState.pressed
    onReleased: root.state = ClickableState.hover
    onEntered: root.state = ClickableState.hover
    onExited: root.state = ClickableState.idle

    // --- states ---
    states: [
        State {
            name: ClickableState.idle
            PropertyChanges { target: container; scale: 1.0; }
            PropertyChanges { target: container; radius: root.radius; }
            PropertyChanges { target: container; color: root.style.background.idle; border.color: root.style.border.idle; }
        },
        State {
            name: ClickableState.hover
            PropertyChanges { target: container; scale: 1; }
            PropertyChanges { target: container; radius: root.radius*2; }
            PropertyChanges { target: container; color: root.style.background.active; border.color: root.style.border.active; }
        },
        State {
            name: ClickableState.pressed
            PropertyChanges { target: container; scale: 0.94; }
            PropertyChanges { target: container; radius: root.radius*2; }
            PropertyChanges { target: container; color: root.style.background.active; border.color: root.style.border.active; }
        }
    ]
    
    Rectangle {
        id: container
        anchors.left: parent.left
        scale: 1.0

        height: parent.height // Follow root height

        color: root.style.background.idle
        border.color: root.style.border.idle
        border.width: root.style.borderWidth

        radius: root.radius
        clip: true
        // antialiasing: true

        Behavior on scale { NumberAnimation { duration: Style.animations.duration/2; } }
        Behavior on radius { NumberAnimation { duration: Style.animations.duration/2; } }
        Behavior on color { ColorAnimation { duration: Style.animations.duration/2; } }
        Behavior on border.color { ColorAnimation { duration: Style.animations.duration/2; } }
    }
}