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
        spacing: 20

        RowLayout {
            spacing: 20
            Layout.fillWidth: true

            BatteryControl {}

            Item { Layout.fillWidth: true }

            Clickable {
                Layout.alignment: Qt.AlignTop
                icon: ""
            }
        }
        
        BrightnessControl {
            Layout.fillWidth: true
        }

        PowerControl {
            Layout.fillWidth: true
        }

        // --- Power Profiles Selector ---
        RowLayout {
            Layout.fillWidth: true
            spacing: DefaultStyle.widgets.spacing
            
            ModeControl { icon: ""; label: "Performance"; target: PowerProfile.Performance; color: DefaultStyle.color_red; }
            ModeControl { icon: ""; label: "Balanced"; target: PowerProfile.Balanced; color: DefaultStyle.color_yellow; }
            ModeControl { icon: ""; label: "Power Saver"; target: PowerProfile.PowerSaver; color: DefaultStyle.color_green; }
        }
    }
}
