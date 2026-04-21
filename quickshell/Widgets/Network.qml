import QtQuick
import Quickshell

import qs
import qs.Style
import qs.Services
import qs.Utilities

// Network.qml
// Status bar widget for network information and quick actions
//
// States:
//   • Connected to internet via wired connection
//   • Connected to internet via wireless connection
//        • Display current SSID
//   • Disconnected
//        • Offline with no connectivity
//        • Offline but retrying connections in background
//
// Icons and colors vary based on state changes and ongoing actions

WidgetBase {
    id: widget

    // "" "" "" "" "󰑓"
    label: `GDBus Monitor: ${Networking.isRunning} | Networking Enabled: ${Networking.networkingEnabled} | Connectivity State: ${Networking.connectivity} | WiFi Enabled: ${Networking.wifiEnabled} | Scanning: ${Networking.scanning} | SSID: ${Networking.activeSsid ?? "None"} | Strength: ${Networking.signalStrength}% | Wired Connection: ${Networking.isWired}`
}