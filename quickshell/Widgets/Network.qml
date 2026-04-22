import QtQuick
import Quickshell

import NetworkMonitorPlugin

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

    readonly property int critical_threshold: 25
    readonly property int degraded_threshold: 60

    readonly property var scan_with_stopwatch: Stopwatch.create(widget)
    readonly property int global_offline_index: 40
    readonly property var state_label_map: ({
        10: { icon: "", label: "Asleep", color: Theme.color_slate },
        20: { icon: "", label: "Offline", color: Theme.color_red },
        30: { icon: "", label: "Disconnecting", color: Theme.color_yellow },
        40: { icon: "", label: "Connecting", color: Theme.color_yellow },
        50: { icon: "", label: "Connected (Site Only)", color: Theme.color_green },
        60: { icon: "", label: "Connected (Local Only)", color: Theme.color_green },
        70: { icon: "", label: "Connected", color: Theme.color_green }
    })

    property int global_state_index: NetworkMonitor.GlobalState ?? 0
    property var active_device: NetworkMonitor.ActiveDevice
    property var active_access_point: NetworkMonitor.ActiveAccessPoint

    readonly property var state: {
        return (() => {
            switch (global_state_index) {
                case 10: return { icon: "", label: "Asleep", color: Theme.color_slate };
                case 20: return { icon: "", label: "Disconnected", color: Theme.color_slate };
                case 30: return { icon: "", label: "Disconnecting", color: Theme.color_yellow };
                case 40: return { icon: "", label: "Connecting", color: Theme.color_yellow };
                case 50: return { icon: "", label: "Limited (Site)", color: Theme.color_green };
                case 60: return { icon: "", label: `${active_access_point.Ssid} (Limited)`, color: Theme.color_blue };
                case 70: 
                    const e = { 
                        icon: "", 
                        label: `${active_access_point.Ssid} (${active_access_point.Strength}%)`, 
                        color: Theme.color_red
                    };
                    const _strength = active_access_point?.Strength;
                    if (!_strength) return e;
                    
                    e.color = 
                        (_strength < critical_threshold) ? Theme.color_red 
                            : (_strength < degraded_threshold) ? Theme.color_yellow 
                                : Theme.color_green;
                    return e;
                default: return { icon: "", label: "Unknown", color: Theme.color_red };
            }
        })();
    }

    icon: state.icon
    label: state.label
    style.foreground.idle: state.color

    // "" "" "" "" "󰑓"
    // label: `GDBus Monitor: ${Networking.isRunning} | Networking Enabled: ${Networking.networkingEnabled} | Connectivity State: ${Networking.connectivity} | WiFi Enabled: ${Networking.wifiEnabled} | Scanning: ${Networking.scanning} | SSID: ${Networking.activeSsid ?? "None"} | Strength: ${Networking.signalStrength}% | Wired Connection: ${Networking.isWired}`

    onClicked: () => {
        if (global_state_index > global_offline_index) {
            active_device && active_device.DevicePath && NetworkControl.DisconnectDevice(active_device.DevicePath);
        } else {
            const _devices = NetworkControl.GetDevices();
            const _network_device = _devices.find((e) => e.DeviceType === 2) ?? _devices.find((e) => e.DeviceType === 30);

            widget.icon = "󰑓";
            scan_with_stopwatch.begin(2000, () => {
                const _known_networks = NetworkControl.GetKnownNetworksInRange(_network_device.DevicePath);
                _known_networks.sort((a, b) => {
                    if (a.Saved !== b.Saved) return b.Saved - a.Saved;
                    
                    // Fixed key name here:
                    if (a.Saved && (a.LastConnected !== b.LastConnected)) {
                        return b.LastConnected - a.LastConnected;
                    }
                    
                    return b.Strength - a.Strength;
                });

                if (_known_networks.length === 0) return;
                
                const _best_network = _known_networks[0];
                if (!_best_network.Saved) return;

                NetworkControl.ActivateConnection(_network_device.DevicePath, _best_network.SettingsPath, _best_network.AccessPointPath);
                widget.icon = state_label_map[global_state_index].icon;
            });
            NetworkControl.RequestScan(_network_device.DevicePath);
        }
    }

    Connections {
        target: NetworkMonitor
        function onScanFinished() { scan_with_stopwatch.end(); }
    }

    // Repeater {
    //     model: 4
    //     Rectangle {
    //         width: 4
    //         height: (index + 1) * 4
    //         // Map 0-100 strength to 4 bars
    //         // Bar 0 lights up at > 0%, Bar 1 at > 25%, etc.
    //         color: (NetworkMonitor.activeAccessPoint.Strength > (index * 25)) 
    //                ? "white" 
    //                : "gray"
    //         opacity: (NetworkMonitor.activeAccessPoint.Strength > (index * 25)) ? 1.0 : 0.3
    //     }
    // }
}