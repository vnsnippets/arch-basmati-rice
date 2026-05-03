pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

import qs
import qs.Styles
import qs.Utilities

WrapperMouseArea {
    id: root
    readonly property var _states: ({ Idle: "IDLE", Pressed: "PRESSED", Hover: "HOVER" })

    default property alias contentData: content.data

    property int radius: Style.border_radius

    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property ColorScheme style: ColorScheme {}
    
    width: implicitWidth

    implicitWidth: content.childrenRect.width + Style.widgets.padding
    implicitHeight: Style.widgets.height

    Layout.alignment: Qt.AlignCenter
    
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onPressed: root.state = _states.Pressed
    onReleased: root.state = _states.Hover
    onEntered: root.state = _states.Hover
    onExited: root.state = _states.Idle

    // --- states ---
    states: [
        State {
            name: _states.Idle
            PropertyChanges { target: container; scale: 1.0; }
            PropertyChanges { target: container; color: root.style.background.idle; border.color: root.style.border.idle; }
        },
        State {
            name: _states.Hover
            PropertyChanges { target: container; scale: 0.96; }
            PropertyChanges { target: container; color: root.style.background.active; border.color: root.style.border.active; }
        },
        State {
            name: _states.Pressed
            PropertyChanges { target: container; scale: 0.94; }
            PropertyChanges { target: container; color: root.style.background.active; border.color: root.style.border.active; }
        }
    ]

    // --- Transitions ---
    transitions: [
        Transition {
            from: "*"
            to: "*"
            ParallelAnimation {
                NumberAnimation { properties: "scale"; duration: Style.animations.duration; easing.type: Easing.OutCubic ; }
                ColorAnimation { properties: "color,border.color"; duration: Style.animations.duration; easing.type: Easing.OutCubic; }
            }
        }
    ]

    Behavior on width { NumberAnimation { duration: Style.animations.duration; easing.type: Easing.OutCubic; } }
    
    Rectangle {
        id: container
        anchors.fill: parent
        scale: 1.0

        color: style.background.idle
        border.color: style.border.idle
        border.width: Style.border_width

        radius: root.radius

        Item { 
            id: content
            anchors.centerIn: parent 
        }
    }
}