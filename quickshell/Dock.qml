pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

import qs.Styles
import qs.Types
import qs.Widgets.Audio
import qs.Widgets.Battery
import qs.Widgets.Caffeine
import qs.Widgets.Clock
import qs.Widgets.Dashboard
import qs.Widgets.Network
import qs.Widgets.Power
import qs.Widgets.Workspaces

import qs.Views

RowLayout {
    id: root
    spacing: Style.dock.spacing

    anchors.topMargin: Style.dock.margin
    anchors.leftMargin: Style.dock.margin
    anchors.rightMargin: Style.dock.margin

    // --- LEFT ---
    RowLayout {
        spacing: Style.dock.spacing

        ClockWidget { format: "yyyy-MM-dd HH:mm" }
        WorkspaceControl { style.border.active: Style.color_light }
    }

    Item { 
        Layout.fillWidth: true 
        // Layout.fillHeight: true

        // Clickable {
        //     implicitWidth: Style.widgets.width
        //     implicitHeight: Style.widgets.height

        //     // TODO: Fix position - it is off center slightly
        //     x: (canvas.width - implicitWidth)/2 - parent.x

        //     Text {
        //         id: label
        //         anchors.centerIn: parent
        //         text: ""
        //         rotation: canvas.dashboardOpen ? 180 : 0
        //         color: Style.dashboard.colors.text
                
        //         Behavior on rotation { 
        //             NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
        //         }
        //     }

        //     onClicked: canvas.dashboardOpen = !canvas.dashboardOpen
        // }
    }

    // --- RIGHT ---
    RowLayout {
        spacing: Style.dock.spacing

        NetworkWidget  {
            popup: NetworkPopup {}
            showLabel: false
            color_disconnected: Style.color_muted
            color_connecting: Style.color_yellow
            color_connected_default: Style.color_green
            color_connected_critical: Style.color_red
            color_connected_limited: Style.color_yellow
        }

        AudioWidget {
            color_inactive: Style.color_slate
            color_default: Style.color_teal    
        }

        BatteryWidget {
            popup: BatteryPopup {}
            color_critical: Style.color_red
            color_warning: Style.color_yellow
            color_charging: Style.color_yellow
            color_default: Style.color_green
        }

        CaffeineWidget {
            color_caffeineon: Style.color_red
            color_caffeineoff: Style.color_blue
        }

        PowerWidget {
            Layout.alignment: Qt.AlignTop
            style.text.idle: Style.color_red
            style.background.active: Style.color_red
            style.text.active: Style.color_dark
            style.border.active: Style.color_red
        }
    }
}