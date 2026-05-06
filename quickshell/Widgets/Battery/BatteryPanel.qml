pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell

import qs
import qs.Types
import qs.Styles
import qs.Controls
import qs.Utilities
import qs.Widgets.Battery.Controls

PanelWrapper {
    implicitWidth: container.width + Style.panel.padding * 2
    implicitHeight: container.height + Style.panel.padding * 2

    position: PanelPosition.right

    ColumnLayout {
        id: container
        anchors.centerIn: parent
        spacing: Style.panel.spacing

        BatteryStatus { Layout.fillWidth: true }
        BrightnessControl { Layout.fillWidth: true }
        PerformanceModes { Layout.fillWidth: true }

        // --- Power Profiles Selector ---
        // ModeControl { Layout.fillWidth: true }
    }
}