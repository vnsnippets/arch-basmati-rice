import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
import qs.Types
import qs.Styles
import qs.Controls
import qs.Utilities

ShellRoot {
    id: shell
    readonly property bool _DEBUG_MODE_: Quickshell.env("DEBUG") === "1"

    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: root
            required property var modelData

            PanelWindow {
                id: barSpace
                screen: modelData

                anchors { top: true; left: true; right: true }
                implicitHeight: Style.dock.height
                WlrLayershell.layer: WlrLayer.Bottom

                color: "transparent"
            }

            PanelWindow {
                id: canvas
                screen: modelData

                // Full screen — anchored to all four edges
                anchors { top: true; left: true; right: true; bottom: true; }
                margins { top: Style.margin; left: Style.margin; right: Style.margin; bottom: Style.margin; } 

                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "qs-basmati-canvas"

                color: "transparent"
                surfaceFormat.opaque: false
                focusable: false

                mask: Region {
                    Region { item: dock }
                    Region { item: (panelRight.item) ? panelRight : null }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: canvas.dashboardOpen ? 0.3 : 0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                    
                    MouseArea {
                        anchors.fill: parent
                        onPressed: canvas.dashboardOpen = false
                    }
                }

                Dock {
                    id: dock
                    anchors.top: parent.top;
                    anchors.left: parent.left;
                    anchors.right: parent.right; 
                }

                PanelContainer {
                    id: panelRight
                    anchors.right: parent.right
                }
            }
        }
    }
}
