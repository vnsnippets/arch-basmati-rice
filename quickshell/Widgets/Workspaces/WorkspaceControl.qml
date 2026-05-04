pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland

import qs
import qs.Styles
import qs.Types.Components
import qs.Types.Styles
import qs.Types.States

Rectangle {
    id: root

    property bool filterByMonitor: true

    readonly property int dotSize: 26
    readonly property int dotRadius: 8
    readonly property int dotActiveSize: 32

    implicitHeight: Style.widget.height
    implicitWidth: repeatable.implicitWidth + (Style.widget.height-dotSize)

    radius: Style.border_radius
    color: Style.color_dark

    readonly property var filteredWorkspaces: {
        const screenName = canvas.screen?.name;
        const rawWorkspaces = Array.from(Hyprland.workspaces.values);

        if (root.filterByMonitor) {
            // OPTIMIZED PATH: 
            // Only get current monitor workspaces and do a simple ID sort.
            return rawWorkspaces
                .filter(ws => ws.monitor?.name === screenName)
                .sort((a, b) => a.id - b.id);
        } else {
            // EXTRA WORK PATH: 
            // Keep all workspaces and apply the "Other Monitors to Front" priority.
            return rawWorkspaces.sort((a, b) => {
                const aIsOther = a.monitor?.name !== screenName;
                const bIsOther = b.monitor?.name !== screenName;

                // Priority 1: Screen locality
                if (aIsOther && !bIsOther) return -1;
                if (!aIsOther && bIsOther) return 1;

                // Priority 2: Numerical ID
                return a.id - b.id;
            });
        }
    }

    RowLayout {
        id: repeatable
        anchors.centerIn: parent
        spacing: Style.widget.spacing

        Repeater {
            // Ensure at least 5 dots are displayed
            model: root.filteredWorkspaces.length

            Clickable {
                id: dot

                required property int modelData
                readonly property int index: modelData
                
                // Get the workspace object if it exists for this index
                readonly property var ws: root.filteredWorkspaces[index]
                readonly property bool isActive: Hyprland.focusedWorkspace?.id === ws?.id
                // readonly property bool hasWindows: ws?.toplevels?.count > 0 ?? false

                readonly property bool isOtherMonitor: !root.filterByMonitor && 
                                                        ws && 
                                                        ws.monitor?.name !== canvas.screen?.name

                Layout.preferredHeight: root.dotSize
                implicitWidth: isActive ? dotActiveSize : root.dotSize
                radius: dotRadius

                // Dynamic Styling
                style: ClickableStyle {
                    background.idle: {
                        // If workspace exists and has windows
                        if (ws && ws.toplevels?.values?.length > 0) {
                            return Qt.alpha(Style.color_light, 0.30)
                        }
                        // Default color for "empty" placeholder dots (if workspaces < 5)
                        return Style.color_slate
                    }
                    background.active: Style.color_slate
                }

                // Only allow clicking if the workspace actually exists
                onClicked: if (ws) ws.activate();

                Behavior on implicitWidth {
                    NumberAnimation { duration: 200; easing.type: Easing.OutQuint }
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰍹" // "󱂬" "" "" "󰍺" "󰍹"
                    visible: dot.isOtherMonitor
                    color: Style.color_light
                    font.pixelSize: 12
                    font.family: Style.fonts.icon
                    Layout.alignment: Qt.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Clickable {
            Layout.preferredHeight: root.dotSize
            implicitWidth: root.dotSize
            radius: dotRadius

            style.background.idle: Style.color_slate
            style.background.active: Style.color_slate

            Text {
                anchors.centerIn: parent
                text: ""
                color: Style.color_light
                font.pixelSize: 12
                font.family: Style.fonts.icon
            }

            onClicked: Hyprland.dispatch(`workspace ${Hyprland.workspaces.values.length + 1}`);
        }
    }
}