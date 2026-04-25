import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets

import qs.Utilities
import qs.Widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: statusbar
        
        required property var modelData
        screen: modelData

        implicitHeight: Theme.size

        anchors { top: true; left: true; right: true; }
        margins { top: Theme.margin; bottom: 0; left: Theme.margin; right: Theme.margin; }
        
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacing

            // --- LEFT ---
            RowLayout {
                id: section_start
                spacing: Theme.spacing
                Clock { format: "yyyy-MM-dd HH:mm" }
            }

            // --- MIDDLE: Workspace Dots ---
            Rectangle {
                readonly property int offset: section_end.width - section_start.width

                Layout.fillWidth: true
                height: statusbar.height
                Layout.leftMargin: Math.max(offset, 0)
                Layout.rightMargin: Math.max(-offset, 0)

                color: "transparent"

                Workspaces { 
                    screen: statusbar.screen
                }
            }

            // --- RIGHT ---
            RowLayout {
                id: section_end
                spacing: Theme.spacing

                Network  { }
                Volume   { }
                Battery  { }
                Profile  { }
                Caffeine { }
                Power    { }
            }
        }
    }
}