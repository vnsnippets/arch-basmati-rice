import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets

import qs.Styles
import qs.Widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: statusbar
        
        required property var modelData
        screen: modelData

        implicitHeight: DefaultStyle.widgets.size

        anchors { top: true; left: true; right: true; }
        margins { 
            top: DefaultStyle.widgets.margin
            bottom: 0
            left: DefaultStyle.widgets.margin
            right: DefaultStyle.widgets.margin
        }
        
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: DefaultStyle.widgets.spacing

            // --- LEFT ---
            RowLayout {
                id: section_start
                spacing: DefaultStyle.widgets.spacing
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
                    style.border.active: DefaultStyle.color_light
                }
            }

            // --- RIGHT ---
            RowLayout {
                id: section_end
                spacing: DefaultStyle.widgets.spacing

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