import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import qs
import qs.Styles
import qs.Utilities

Rectangle {
    id: root

    default property alias content: custom.data

    property string icon: ""
    property string label: ""
    property string tooltip: ""
    property bool interactive: true

    property QtObject locks: QtObject {
        property bool hover: false
        property bool pressed: false
    }

    property ColorScheme style: ColorScheme {}
    
    signal clicked()
    signal doubleClicked()
    signal scrolled(var wheel)

    scale: 1.0
    color: style.background.idle
    border.color: style.border.idle
    border.width: DefaultStyle.widgets.border

    // radius: height / DefaultStyle.widgets.roundness
    radius: DefaultStyle.widgets.radius
    width: implicitWidth

    implicitWidth: label === "" ? DefaultStyle.widgets.size : content.width + DefaultStyle.widgets.padding
    implicitHeight: DefaultStyle.widgets.size

    Layout.alignment: Qt.AlignCenter
    // Layout.preferredHeight: DefaultStyle.widgets.size

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: DefaultStyle.widgets.spacing

        Text {
            id: icon_text
            text: icon
            color: root.style.icon.idle
            font.pixelSize: DefaultStyle.fonts.size
            font.family: DefaultStyle.fonts.icon
            visible: text !== ""
            Layout.margins: 0
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            id: label_text
            text: label
            color: root.style.text.idle
            font.pixelSize: DefaultStyle.fonts.size
            font.family: DefaultStyle.fonts.family
            visible: text !== ""
            Layout.margins: 0
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        RowLayout {
            id: custom
            visible: children.length > 0 && children.some((c) => c.width > 0)
            spacing: DefaultStyle.widgets.spacing
            Layout.alignment: Qt.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: (interactive) ? Qt.PointingHandCursor : Qt.ArrowCursor

        onClicked: if (interactive) root.clicked()
        onDoubleClicked: if (interactive) root.doubleClicked()
        onWheel: (wheel) => { if (interactive) root.scrolled(wheel) }

        onPressed: if (interactive) root.state = "pressed"
        onReleased: if (interactive) root.state = "hover"
        onEntered: if (interactive) root.state = "hover"
        onExited: root.state = "idle"
    }

    // --- states ---
    states: [
        State {
            name: "idle"
            PropertyChanges { 
                target: root
                scale: 1.0
                color: root.style.background.idle
                border.color: root.style.border.idle
            }
            PropertyChanges { 
                target: icon_text
                color: root.style.icon.idle
            }
            PropertyChanges {
                target: label_text
                color: root.style.text.idle
            }
        },
        State {
            name: "hover"
            PropertyChanges { 
                target: root
                scale: 0.96
                color: root.style.background.active
                border.color: root.style.border.active
            }
            PropertyChanges {
                target: icon_text
                color: root.style.icon.active
            }
            PropertyChanges { 
                target: label_text
                color: root.style.text.active
            }
        },
        State {
            name: "pressed"
            PropertyChanges {
                target: root
                scale: 0.94
                color: root.style.background.active
                border.color: root.style.border.active
            }
            PropertyChanges { 
                target: icon_text
                color: root.style.icon.active
            }
            PropertyChanges {
                target: label_text
                color: root.style.text.active
            }
        }
    ]

    // --- Transitions ---
    transitions: [
        Transition {
            from: "*"
            to: "*"
            ParallelAnimation {
                NumberAnimation {
                    properties: "scale"
                    duration: DefaultStyle.animations.duration
                    easing.type: Easing.OutCubic 
                }
                ColorAnimation {
                    properties: "color"
                    duration: DefaultStyle.animations.duration
                    easing.type: Easing.OutCubic
                }
                ColorAnimation { 
                    properties: "border.color"
                    duration: DefaultStyle.animations.duration
                    easing.type: Easing.OutCubic
                }
                ColorAnimation { 
                    properties: "color"
                    target: icon_text
                    duration: DefaultStyle.animations.duration
                    easing.type: Easing.OutCubic
                }
                ColorAnimation { 
                    properties: "color"
                    target: label_text
                    duration: DefaultStyle.animations.duration
                    easing.type: Easing.OutCubic
                }
            }
        }
    ]

    Behavior on width {
        SpringAnimation {
            spring: 15      // stiffness of the spring
            damping: 0.25   // how quickly it settles
        }
    }

    Component.onCompleted: root.state = "idle"
}