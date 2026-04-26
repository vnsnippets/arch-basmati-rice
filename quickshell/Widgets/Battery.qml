import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles

Base {
    id: container

    // Icons for battery levels
    readonly property var batteryIcons: [
        "", // 0–20%
        "", // 21–40%
        "", // 41–60%
        "", // 61–80%
        ""  // 81–100%
    ]
    readonly property string chargingIcon: ""

    property color color_critical: null
    property color color_warning: null
    property color color_charging: null
    property color color_default: null

    // Bind to displayDevice (the laptop battery)
    property int percentage: Math.round(UPower.displayDevice.percentage * 100)
    property int state: UPower.displayDevice.state

    // Charging if state is 1 or 5
    property bool charging: state === 1 || state === 5

    // Icon selection
    property string currentIcon: charging
        ? chargingIcon
        : batteryIcons[Math.min(4, Math.floor(percentage / 20))]

    // Display
    icon: currentIcon
    label: percentage + "%"
    tooltip: charging ? "Charging (" + percentage + "%)" : "Battery " + percentage + "%"

    // Style logic
    style.text.idle: {
        if (charging) {
            return color_charging
        } else if (percentage <= Context.battery.critical_threshold) {
            return color_critical
        } else if (percentage <= Context.battery.warning_threshold) {
            return color_warning
        } else {
            return color_default
        }
    }    
}
