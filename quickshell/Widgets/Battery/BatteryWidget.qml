import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Controls

Clickable {
    id: root
    implicitWidth: content.width + Style.clickable.padding

    // Defaults to references
    required property color color_critical
    required property color color_warning
    required property color color_charging
    required property color color_default

    property int batteryPercentage: Math.round(device.percentage * 100)

    property bool isCharging: device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge

    readonly property var device: UPower.displayDevice
    readonly property color textColor: {
        if (root.device.state === UPowerDeviceState.Charging) return color_charging;
        if (batteryPercentage <= Context.battery.criticalLimit) return color_critical;
        if (batteryPercentage <= Context.battery.warningLimit) return color_warning;
        return color_default;
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Style.clickable.spacing

        StyledText {
            id: icon
            text: isCharging ? "" : ["", "", "", "", ""][Math.min(4, Math.floor(batteryPercentage / 21))]
            color: textColor
        }

        StyledText {
            id: label
            text: batteryPercentage + "%"
            color: textColor
        }
    }
}
