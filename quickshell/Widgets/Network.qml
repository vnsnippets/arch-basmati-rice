import QtQuick
import QtQuick.Layouts
import Quickshell

import NetworkMonitorPlugin

import qs
import qs.Style
import qs.Services
import qs.Utilities

/**
* Network.qml
* Status bar widget for network information and quick actions
*
* States:
*   • Connected to internet via wired connection
*   • Connected to internet via wireless connection
*        • Display current SSID
*   • Disconnected
*        • Offline with no connectivity
*        • Offline but retrying connections in background
*
* Icons and colors vary based on state changes and ongoing actions
* "" "" "" "" "󰑓"
**/

WidgetBase {
    id: widget

    readonly property QtObject state: StateProvider.network_widget

    property int critical_threshold: 25
    readonly property int degraded_threshold: 60
    readonly property int recency_threshold : 2592000 // 30 days

    readonly property int strength_levels: 5

    readonly property int global_offline_index: 40

    property int global_state_index: NetworkMonitor.GlobalState ?? 0
    property var active_device: NetworkMonitor.ActiveDevice
    property var active_access_point: NetworkMonitor.ActiveAccessPoint

    readonly property var ui: {
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
                        label: active_access_point.Ssid, 
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

    icon: state.scan_with_stopwatch?.running ? "󰑓" : ui.icon
    label: ui.label
    style.foreground.idle: ui.color

    Row {
        spacing: 2
        Layout.leftMargin: 1 // The "break" from the label
        Layout.alignment: Qt.AlignVCenter
        Repeater {
            id: strength_meter_container
            model: strength_levels
            Rectangle {
                width: 4
                height: 12
                radius: 2
                color: (state.scan_with_stopwatch?.running) ? Theme.color_slate : 
                    (active_access_point?.Strength > (index * 100/strength_levels)) ? ui.color : Theme.color_slate
                opacity: (active_access_point.Strength > (index * 100/strength_levels)) ? 1.0 : 0.3
                Behavior on color { ColorAnimation { duration: Theme.duration } }
                Behavior on opacity { NumberAnimation { duration: Theme.duration } }
            }
        }
    }

    onClicked: () => {
        if (global_state_index > global_offline_index) {
            active_device && active_device.DevicePath && NetworkControl.DisconnectDevice(active_device.DevicePath);
        } else {
            const _devices = NetworkControl.GetAllDevices();
            const _network_device = _devices.find((e) => e.DeviceType === 2) ?? _devices.find((e) => e.DeviceType === 30);

            state.scan_with_stopwatch.begin(2000, () => {
                const _known_networks = NetworkControl.GetKnownNetworksInRange(_network_device.DevicePath);
                _known_networks.sort((a, b) => {
                    // 1. Primary: Always prioritize Saved networks over guest/random ones
                    if (a.Saved !== b.Saved) return b.Saved - a.Saved;
                    
                    // 2. Prioritize recent connections (86400 for a full day) 
                    const now = Math.floor(Date.now() / 1000); // Current Unix time
                    
                    const aIsRecent = a.Saved && (now - a.LastConnected) < recency_threshold;
                    const bIsRecent = b.Saved && (now - b.LastConnected) < recency_threshold;

                    // If one is recent and the other isn't, the recent one wins
                    if (aIsRecent !== bIsRecent) return bIsRecent ? 1 : -1;

                    // 3. Tie-breaker for Recency
                    // If both are recent, or both are old/unsaved, look at signal strength. 
                    // If strengths are within 5% of each other, choose the most recent connection.
                    const strengthDiff = Math.abs(a.Strength - b.Strength);
                    if (strengthDiff > 5) {
                        return b.Strength - a.Strength;
                    }

                    // 4. Final Fallback: If strengths are nearly equal, most recent connection wins
                    return b.LastConnected - a.LastConnected;
                });

                if (_known_networks.length === 0) return;

                const _best_network = _known_networks[0];
                if (!_best_network.Saved) return;

                NetworkControl.ActivateConnection(_network_device.DevicePath, _best_network.SettingsPath, _best_network.AccessPointPath);
            });
            NetworkControl.RequestScan(_network_device.DevicePath);
        }
    }

    Connections {
        target: NetworkMonitor
        function onScanFinished() { state.scan_with_stopwatch.end(); }
    }

    Component.onCompleted: () => {
        widget.state.scan_with_stopwatch =  Stopwatch.create(widget);
    }
}