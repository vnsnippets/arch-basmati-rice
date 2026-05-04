pragma ComponentBehavior: Bound

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

import qs.Views
import qs.Types.Components

Item {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top

    anchors.leftMargin: Style.dock.margin
    anchors.rightMargin: Style.dock.margin

    // --- LEFT ---
    RowLayout {
        anchors.top: parent.top;
        anchors.left: parent.left;
        anchors.verticalCenter: parent.verticalCenter;

        ClickableWithIconAndLabel {
            icon: ""
        }

        ClockWidget {
            radius: Style.widget.radius
            style.background.idle: Style.widget.colors.background
        }
    }

    WidgetGroup {
        anchors.verticalCenter: parent.verticalCenter;
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: Style.dock.spacing
        offset: 12
        radius: implicitWidth/2
        WorkspaceControl {
            filterByMonitor: false
        }
    }

    // --- RIGHT ---
    RowLayout {
        anchors.top: parent.top;
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter;

        spacing: Style.dock.spacing

        NetworkWidget  {
            popup: NetworkPopup {}
            showLabel: false
            color_disconnected: Style.colors.subtext0
            color_connecting: Style.colors.yellow
            color_connected_default: Style.colors.green
            color_connected_critical: Style.colors.red
            color_connected_limited: Style.colors.yellow

            radius: Style.widget.radius
            style.background.idle: Style.widget.colors.background
        }

        AudioWidget {
            color_inactive: Style.colors.base
            color_default: Style.colors.blue

            radius: Style.widget.radius
            style.background.idle: Style.widget.colors.background
        }

        BatteryWidget {
            popup: BatteryPopup {}
            color_critical: Style.colors.red
            color_warning: Style.colors.yellow
            color_charging: Style.colors.yellow
            color_default: Style.colors.green

            radius: Style.widget.radius
            style.background.idle: Style.widget.colors.background
        }

        CaffeineWidget {
            color_caffeineon: Style.colors.red
            color_caffeineoff: Style.colors.blue

            radius: Style.widget.radius
            style.background.idle: Style.widget.colors.background
        }

        PowerWidget {
            style.text.idle: Style.colors.red
            style.background.active: Style.colors.red
            style.text.active: Style.colors.mantle
            style.border.active: Style.colors.red

            radius: Style.widget.radius
            style.background.idle: Style.widget.colors.background
        }

        ClickableWithIconAndLabel {
            icon: ""
        }
    }
}