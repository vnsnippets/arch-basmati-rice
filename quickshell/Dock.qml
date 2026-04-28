import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

import qs.Styles
import qs.Widgets.Audio
import qs.Widgets.Battery
import qs.Widgets.Caffeine
import qs.Widgets.Clock
import qs.Widgets.Network
import qs.Widgets.Power
import qs.Widgets.Workspaces

RowLayout {
    id: root
    anchors.fill: parent
    spacing: DefaultStyle.widgets.spacing

    // --- LEFT ---
    RowLayout {
        id: section_start
        spacing: DefaultStyle.widgets.spacing
        ClockWidget { 
            format: "yyyy-MM-dd HH:mm"
        }
    }

    // --- MIDDLE: Workspace Dots ---
    Rectangle {
        readonly property int offset: section_end.width - section_start.width

        Layout.fillWidth: true
        implicitHeight: parent.height
        Layout.leftMargin: Math.max(offset, 0)
        Layout.rightMargin: Math.max(-offset, 0)

        color: "transparent"

        WorkspaceControl { 
            style.border.active: DefaultStyle.color_light
        }
    }

    // --- RIGHT ---
    RowLayout {
        id: section_end
        spacing: DefaultStyle.widgets.spacing

        NetworkWidget  {
            color_disconnected: DefaultStyle.color_slate
            color_connecting: DefaultStyle.color_yellow
            color_connected_default: DefaultStyle.color_green
            color_connected_critical: DefaultStyle.color_red
            color_connected_limited: DefaultStyle.color_yellow
        }

        AudioWidget {
            color_inactive: DefaultStyle.color_slate
            color_default: DefaultStyle.color_teal    
        }

        BatteryWidget {
            color_critical: DefaultStyle.color_red
            color_warning: DefaultStyle.color_yellow
            color_charging: DefaultStyle.color_yellow
            color_default: DefaultStyle.color_green
        }

        CaffeineWidget {
            color_caffeineon: DefaultStyle.color_red
            color_caffeineoff: DefaultStyle.color_blue
        }

        PowerWidget {
            style.text.idle: DefaultStyle.color_red
            style.background.active: DefaultStyle.color_red
            style.text.active: DefaultStyle.color_dark
            style.border.active: DefaultStyle.color_red
        }
    }
}