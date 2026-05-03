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
    readonly property var _states: ({ Idle: "IDLE", Pressed: "PRESSED", Hover: "HOVER", Active: "ACTIVE" })

    property string icon: ""
    property string label: ""

    property int radius: Style.border_radius

    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property ColorScheme style: ColorScheme {}
    
    width: implicitWidth

    implicitWidth: label === "" ? Style.widgets.width : content.width + Style.widgets.padding
    implicitHeight: Style.widgets.height

    Layout.alignment: Qt.AlignCenter

    Rectangle {
        id: contentWrapper
        anchors.fill: parent
        scale: 1.0

        color: style.background.idle
        border.color: style.border.idle
        border.width: Style.border_width

        radius: root.radius

        RowLayout {
            id: content
            anchors.centerIn: parent
            spacing: Style.widgets.spacing

            Text {
                id: icon_text
                text: icon
                color: root.style.icon.idle
                font.pixelSize: Style.fonts.size
                font.family: Style.fonts.icon
                visible: text !== ""
                Layout.margins: 0
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: label_text
                text: label
                color: root.style.text.idle
                font.pixelSize: Style.fonts.size
                font.family: Style.fonts.family
                visible: text !== ""
                Layout.margins: 0
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    
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
            PropertyChanges { target: contentWrapper; scale: 1.0; }
            PropertyChanges { target: icon_text; color: root.style.icon.idle; }
            PropertyChanges { target: label_text; color: root.style.text.idle; }
            PropertyChanges { target: contentWrapper; color: root.style.background.idle; border.color: root.style.border.idle; }
        },
        State {
            name: _states.Hover
            PropertyChanges { target: contentWrapper; scale: 0.96; }
            PropertyChanges { target: icon_text; color: root.style.icon.active; }
            PropertyChanges { target: label_text; color: root.style.text.active; }
            PropertyChanges { target: contentWrapper; color: root.style.background.active; border.color: root.style.border.active; }
        },
        State {
            name: _states.Pressed
            PropertyChanges { target: contentWrapper; scale: 0.94; }
            PropertyChanges { target: icon_text; color: root.style.icon.active; }
            PropertyChanges { target: label_text; color: root.style.text.active; }
            PropertyChanges { target: contentWrapper; color: root.style.background.active; border.color: root.style.border.active; }
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
                ColorAnimation { properties: "color"; target: icon_text; duration: Style.animations.duration; easing.type: Easing.OutCubic; }
                ColorAnimation { properties: "color"; target: label_text; duration: Style.animations.duration; easing.type: Easing.OutCubic; }
            }
        }
    ]

    Behavior on width { NumberAnimation { duration: Style.animations.duration; easing.type: Easing.OutCubic; } }
}