import QtQuick
import Quickshell

import qs
import qs.Style
import qs.Services
import qs.Utilities

WidgetBase {
    id: widget

    property int criticalthreshold: 25
    property int warningthreshold: 50

    readonly property bool isWireless: NMCLI.active !== null
    readonly property bool isWired: !isWireless && NMCLI.activeEthernet !== null
    readonly property bool isConnected: isWireless || isWired

    icon: {
        if (!NMCLI.initialized) return "󰑓"
        if (isWireless) return ""
        if (isWired) return ""
        return NMCLI.networkingEnabled ? "󰑓" : "󰤫"
    }

    label: {
        if (!NMCLI.initialized) return "Loading..."
        if (isWireless) return `${NMCLI.active.ssid} (${NMCLI.active.strength}%)`
        if (isWired) return "Wired"
        return "Disconnected"
    }

    style.foreground.idle: {
        if (!NMCLI.initialized) return Theme.color_yellow
        if (isWireless) {
            if (NMCLI.active.strength <= criticalthreshold) return Theme.color_red
            if (NMCLI.active.strength <= warningthreshold) return Theme.color_yellow
            return Theme.color_green
        }
        if (isWired) return Theme.color_green
        return Theme.color_red
    }

    // Refresh signal strength every 5s while on wireless
    Timer {
        interval: 5000
        running: widget.isWireless
        repeat: true
        onTriggered: NMCLI.getNetworks(() => {})
    }

    // Re-enable networking whenever a WiFi connection is successfully established
    Connections {
        target: NMCLI
        function onActiveChanged() {
            if (NMCLI.active && !NMCLI.networkingEnabled) {
                NMCLI.enableNetworking(true, () => {})
            }
        }
    }

    onClicked: () => {
        if (isWireless) {
            // Disconnect active wireless
            NMCLI.disconnectFromNetwork()
        } else if (!isConnected) {
            // Toggle auto-retry (NetworkManager networking) when disconnected
            NMCLI.enableNetworking(!NMCLI.networkingEnabled, () => {})
        }
    }
}
