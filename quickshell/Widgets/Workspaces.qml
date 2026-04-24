import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs
import qs.Utilities

 Repeater {
    id: container
    model: 9

    Layout.preferredWidth: parent.width
    Layout.preferredHeight: parent.height

    readonly property int default_size: 12
    readonly property int active_size:  24

    property var workspace: null;
    property var is_active: null;

    Widget {
        height: default_size
        width: variant.active ? active_size : default_size
        radius: default_size/2

        onClicked: Hyprland.dispatch("workspace " + (index + 1))
    }

    // Rectangle {
    //     color: Theme.color_dark

    //     border.width: Theme.border
    //     border.color: Theme.color_slate

    //     height: default_size
    //     width: variant.active ? active_size : default_size
        
    //     radius: default_size/2

    //     MouseArea {
    //         anchors.fill: parent
    //         onClicked: Hyprland.dispatch("workspace " + (index + 1))
    //     }
    // }

// Repeater {
//     model: 9

//     Rectangle {
//         Layout.preferredWidth: 20
//         Layout.preferredHeight: parent.height
//         color: "transparent"

//         property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
//         property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
//         property bool hasWindows: workspace !== null

//         Text {
//             text: index + 1
//             color: parent.isActive ? root.colCyan : (parent.hasWindows ? root.colCyan : root.colMuted)
//             font.pixelSize: root.fontSize
//             font.family: root.fontFamily
//             font.bold: true
//             anchors.centerIn: parent
//         }

//         Rectangle {
//             width: 20
//             height: 3
//             color: parent.isActive ? root.colPurple : root.colBg
//             anchors.horizontalCenter: parent.horizontalCenter
//             anchors.bottom: parent.bottom
//         }

//         MouseArea {
//             anchors.fill: parent
//             onClicked: Hyprland.dispatch("workspace " + (index + 1))
//         }
//     }
// }
}