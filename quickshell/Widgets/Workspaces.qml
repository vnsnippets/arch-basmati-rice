import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import qs
import qs.Utilities

RowLayout {
    id: container

    anchors.fill: parent
    spacing: Theme.spacing
    Layout.alignment: Qt.AlignCenter

    property var screen: null
    readonly property var allWindows: Hyprland.toplevels.values

    Item { Layout.fillWidth: true }

    Repeater {
        model: Hyprland.workspaces.values.filter((ws) => ws.monitor?.name === screen?.name).sort((a, b) => a.id - b.id);

        Base {
            id: dot
            required property var modelData
            readonly property bool isActive: Hyprland.focusedWorkspace?.id === modelData.id
            readonly property bool hasWindows: allWindows.some((e) => e.workspace.id === modelData.id)

            Layout.preferredHeight: 24
            implicitWidth: (isActive) ? 40 : 24
            radius: 20

            onClicked: modelData.activate()

            Behavior on implicitWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
            }
        }
    }

    Item { Layout.fillWidth: true }
}