pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import qs
import qs.Styles
import qs.Types.Components
import qs.Types.Styles

Rectangle {
    id: root

    implicitHeight: Style.widget.height
    implicitWidth: repeatable.implicitWidth + Style.widget.padding

    radius: Style.border_radius
    color: Style.color_dark

    readonly property var filteredWorkspaces: {
        const screenName = canvas.screen?.name;
        if (!screenName) return [];
        return Hyprland.workspaces.values
            .filter(ws => ws.monitor?.name === screenName)
            .sort((a, b) => a.id - b.id);
    }

    property ClickableStyle style: ClickableStyle {
        background.idle: Style.color_slate
        background.active: Style.color_slate
    }

    RowLayout {
        id: repeatable
        anchors.centerIn: parent
        spacing: Style.widget.spacing

        Repeater {
            model: root.filteredWorkspaces

            Clickable {
                id: dot
                required property var modelData
                readonly property bool isActive: Hyprland.focusedWorkspace?.id === modelData?.id ?? false

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
    }
}