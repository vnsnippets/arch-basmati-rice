import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import qs
import qs.Styles

RowLayout {
    id: root

    anchors.fill: parent
    spacing: DefaultStyle.widgets.spacing
    Layout.alignment: Qt.AlignCenter

    readonly property var allWindows: Hyprland.toplevels.values

    property ColorScheme style: ColorScheme {}

    Item { Layout.fillWidth: true }

    Repeater {
        model: Hyprland.workspaces.values.filter((ws) => ws.monitor?.name === statusbar.screen?.name).sort((a, b) => a.id - b.id) ?? []
        
        Base {
            id: dot
            required property var modelData
            readonly property bool isActive: Hyprland.focusedWorkspace?.id === modelData?.id ?? false
            readonly property bool hasWindows: allWindows.some((e) => e.workspace?.id === modelData?.id) ?? false

            Layout.preferredHeight: 24
            implicitWidth: (isActive) ? 40 : 24
            radius: 20

            style: root.style

            onClicked: modelData.activate()

            Behavior on implicitWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
            }
        }
    }

    Item { Layout.fillWidth: true }
}