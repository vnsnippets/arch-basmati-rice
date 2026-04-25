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

    Item { Layout.fillWidth: true }

    Repeater {
        model: 9
        // model: Hyprland.workspaces.values

        Base {
            // required property var modelData

            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
            property bool is_active: Hyprland.focusedWorkspace?.id === (index + 1)
            property bool has_windows: workspace !== null


            // Access properties directly from the Hyprland Workspace object
            // readonly property bool is_active: Hyprland.focusedWorkspace?.id === modelData.id
            // readonly property bool has_windows: modelData.windows > 0

            Layout.preferredHeight: 24
            implicitWidth: (is_active) ? 40 : 24
            radius: 20

            visible: has_windows || is_active
            style.border.idle: (is_active) ? Theme.color_light : Theme.color_dark

            onClicked: Hyprland.dispatch(`workspace ${modelData.id}`)
        }
    }

    Item { Layout.fillWidth: true }
}