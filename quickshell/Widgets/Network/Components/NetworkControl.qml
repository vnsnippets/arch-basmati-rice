import QtQuick
import QtQuick.Layouts

import Quickshell

import qs
import qs.Styles
import qs.Utilities
import qs.Types.Components

import NetworkMonitorPlugin

RowLayout {
    id: root
    spacing: Style.popup.spacing

    property bool wifiOn: false

    // Flattened properties to avoid object re-creation overhead
    readonly property int networkState: NetworkMonitor.GlobalState
    readonly property var activieWifiDevice: NetworkMonitor.ActiveAccessPoint

    Column {
        Layout.alignment: Qt.AlignVCenter
        Text {
            text: "Connected"
            font.pixelSize: 14
            color: Style.colors.text
            opacity: 0.6
        }
        Text {
            text: (networkState >= 70) ? `${activieWifiDevice?.Ssid} (${activieWifiDevice.Strength}%)` : (networkState >= 60) ? `${activieWifiDevice?.Ssid} (Local)` : (networkState >= 40) ? "Connecting" : "Disconnected"
            font.pixelSize: 16
            color: Style.colors.text
        }
    }

    Row {
        spacing: 8

        ClickableWithIconAndLabel {
            id: wifiToggle
            icon: ""

            style.background.idle: (root.wifiOn) ? Style.colors.blue : Style.colors.mantle
            style.border.idle: (root.wifiOn) ? Style.colors.blue : Style.colors.mantle
            style.text.idle: (root.wifiOn) ? Style.colors.mantle : Style.colors.text

            style.background.active: Style.colors.blue
            style.border.active: Style.colors.blue
            style.text.active: Style.colors.mantle

            onClicked: Daemon.execute(["nmcli", "radio", "wifi", (root.wifiOn) ? "off" : "on"], () => {
                Daemon.execute(["nmcli", "radio", "wifi"], (e) => {
                    if (!e || !e.output) return;
                    root.wifiOn = e.output === "enabled"
                })
            });

            Component.onCompleted: {
                Daemon.execute(["nmcli", "radio", "wifi"], (e) => {
                    if (!e || !e.output) return;
                    root.wifiOn = e.output === "enabled"
                })
            }
        }

        ClickableWithIconAndLabel {
            id: bluetoothToggle
            icon: "󰂯"
        }
    }
}