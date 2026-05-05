pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

import qs

import qs.Styles
import qs.Widgets.Audio
import qs.Widgets.Battery
import qs.Widgets.Caffeine
import qs.Widgets.Network
import qs.Widgets.Workspaces

import qs.Types
import qs.Controls

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

        Clickable {
            StyledText {
                anchors.centerIn: parent
                text: Qt.formatDateTime(Context.clock.date, "yyyy-MM-dd HH:mm")
            }
        }
    }

    FramedGroup {
        anchors.verticalCenter: parent.verticalCenter;
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: Style.dock.spacing
        offset: 12
        radius: implicitWidth/2

        WorkspaceControl { filterByMonitor: true }
    }

    // --- RIGHT ---
    RowLayout {
        anchors.top: parent.top;
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter;

        spacing: Style.dock.spacing

        NetworkWidget  {
            showLabel: false
            color_disconnected: Style.colors.subtext
            color_connecting: Style.colors.yellow
            color_connected_default: Style.colors.green
            color_connected_critical: Style.colors.red
            color_connected_limited: Style.colors.yellow
        }

        AudioWidget {
            color_inactive: Style.colors.base
            color_default: Style.colors.blue
        }

        BatteryWidget {
            color_critical: Style.colors.red
            color_warning: Style.colors.yellow
            color_charging: Style.colors.yellow
            color_default: Style.colors.green
        }

        CaffeineWidget {
            color_caffeineon: Style.colors.red
            color_caffeineoff: Style.colors.blue
        }

        Clickable {
            id: powerWidget            
            backgroundIdleColor: Style.colors.base
            backgroundActiveColor: Style.colors.red
            borderActiveColor: Style.colors.red
            onClicked: Context.process.shutdown = Daemon.execute(["poweroff"]);
            StyledText {
                anchors.centerIn: parent
                text:""
                color: powerWidget.containsMouse ? Style.colors.base : Style.colors.red
            }
        }
        
        Clickable {
            StyledText {
                anchors.centerIn: parent
                text:""
            }

            Component { id: headerComponent; Text { text: "COMPONENT 1"; color: "white"; font.pixelSize: 20 } }
            Component { id: settingsComponent; Text { text: "COMPONENT 2"; color: "white"; font.pixelSize: 20 } }
            Component { id: footerComponent; Text { text: "COMPONENT 3"; color: "white"; font.pixelSize: 20 } }

            property bool panelOpen: false
            onClicked: {
                if (panelOpen) canvas.panel.close();
                else canvas.panel.load(PanelDirection.right, headerComponent, settingsComponent, footerComponent);

                panelOpen = !panelOpen;
            }
        }
    }
}