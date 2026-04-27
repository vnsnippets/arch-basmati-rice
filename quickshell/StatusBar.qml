import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

import qs.Styles
import qs.Widgets

RowLayout {
    id: root
    anchors.fill: parent
    spacing: DefaultStyle.widgets.spacing

    // --- LEFT ---
    RowLayout {
        id: section_start
        spacing: DefaultStyle.widgets.spacing
        Clock { 
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

        Workspaces { 
            style.border.active: DefaultStyle.color_light
        }
    }

    // --- RIGHT ---
    RowLayout {
        id: section_end
        spacing: DefaultStyle.widgets.spacing

        Network  {
            color_disconnected: DefaultStyle.color_slate
            color_connecting: DefaultStyle.color_yellow
            color_connected_default: DefaultStyle.color_green
            color_connected_critical: DefaultStyle.color_red
            color_connected_limited: DefaultStyle.color_yellow
        }

        Volume {
            color_inactive: DefaultStyle.color_slate
            color_default: DefaultStyle.color_teal    
        }

        Battery {
            color_critical: DefaultStyle.color_red
            color_warning: DefaultStyle.color_yellow
            color_charging: DefaultStyle.color_yellow
            color_default: DefaultStyle.color_green
        }
        
        Profile {
            color_powersave: DefaultStyle.color_green
            color_balanced: DefaultStyle.color_yellow
            color_performance: DefaultStyle.color_red
        }

        Caffeine {
            color_caffeineon: DefaultStyle.color_red
            color_caffeineoff: DefaultStyle.color_blue
        }

        Power {
            style.text.idle: DefaultStyle.color_red
            style.background.active: DefaultStyle.color_red
            style.text.active: DefaultStyle.color_dark
            style.border.active: DefaultStyle.color_red
        }
    }
}