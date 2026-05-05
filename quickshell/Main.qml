import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
import qs.Styles
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
                implicitHeight: Style.dock.height + Style.dock.margin
                
                WlrLayershell.layer: WlrLayer.Bottom

                color: "transparent"
            }

            PanelWindow {
                id: canvas
                screen: modelData

                // Full screen — anchored to all four edges
                anchors { top: true; left: true; right: true; }
                implicitHeight: barSpace.implicitHeight

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

                    implicitHeight: Style.dock.height + (Style.dock.margin * 2)
                }
            }
        }
    }
}
