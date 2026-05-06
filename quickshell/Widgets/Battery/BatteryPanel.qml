pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs
import qs.Styles
import qs.Controls
import qs.Utilities
import qs.Widgets.Battery.Controls

PanelWrapper {
    RowLayout {
        Layout.fillWidth: true
        spacing: 20

        BatteryStatus { Layout.fillWidth: true }
    }
    
    BrightnessControl {
        Layout.fillWidth: true
    }

    PerformanceModes { Layout.fillWidth: true }

    // --- Power Profiles Selector ---
    // ModeControl { Layout.fillWidth: true }
}