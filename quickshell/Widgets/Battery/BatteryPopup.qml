pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Widgets
import qs.Utilities
import qs.Widgets.Battery.Components

Popup {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: Style.popup.spacing

        RowLayout {
            spacing: Style.popup.spacing
            Layout.fillWidth: true

            BatteryControl {}

            Item { Layout.fillWidth: true }

            Clickable {
                Layout.alignment: Qt.AlignTop
                icon: ""
                style.background.idle: Style.popup.button.background.idle
                style.background.active: Style.popup.button.background.active
            }
        }
        
        BrightnessControl { Layout.fillWidth: true }
        PowerControl { Layout.fillWidth: true }

        // --- Power Profiles Selector ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            
            ModeControl { icon: ""; label: "Performance"; target: PowerProfile.Performance; color: Style.color_red; }
            ModeControl { icon: ""; label: "Balanced"; target: PowerProfile.Balanced; color: Style.color_yellow; }
            ModeControl { icon: ""; label: "Power Saver"; target: PowerProfile.PowerSaver; color: Style.color_green; }
        }
    }
}
