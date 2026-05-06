import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
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

                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "qs-basmati-canvas"

                color: "transparent"
                surfaceFormat.opaque: false
                focusable: false

                mask: Region {
                    Region { item: dockMask }
                    // Region { item: (canvas.dashboardOpen) ? dashboard : null }
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

                Item {
                    id: dockMask
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    implicitHeight: Style.dock.height                    
                }

                Dock {
                    id: dock
                    z: 10
                    
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }

                    // Add additional margin for bottom margin set by hyprland
                    implicitHeight: Style.dock.height + Style.margin 
                }
            }
        }
    }
}
