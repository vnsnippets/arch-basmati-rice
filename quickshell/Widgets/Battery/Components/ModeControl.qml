import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Types.Components

RowLayout {
    id: root
    spacing: 8

    readonly property var profileMap: [
        { icon: "", label: "Performance", color: Style.colors.red, target: PowerProfile.Performance },
        { icon: "", label: "Balanced", color: Style.colors.yellow, target: PowerProfile.Balanced },
        { icon: "", label: "Power Saver", color: Style.colors.green, target: PowerProfile.PowerSaver }
    ]

    readonly property var activeProfile: profileMap[PowerProfiles.profile]

    Column {
        Layout.fillWidth: true

        Text {
            text: "Profile"
            font.pixelSize: 14
            color: Style.colors.text
            opacity: 0.6
        }

        Text {
            text: root.activeProfile.label
            font.pixelSize: 16
            color: Style.colors.text
        }
    }

    Repeater {
        model: root.profileMap

        delegate: ClickableWithIconAndLabel {
            required property var modelData
            readonly property bool isActive: PowerProfiles.profile === modelData.target

            implicitWidth: Style.widget.width

            // Simplify style logic: if active, it stays its color even when idled
            style.background.idle: isActive ? modelData.color : Style.popup.button.background.idle
            style.text.idle:       isActive ? Style.colors.mantle : Style.colors.text
            style.border.idle:     isActive ? modelData.color : Style.colors.text
            
            style.background.active: modelData.color
            style.text.active:       Style.colors.mantle
            style.border.active:     modelData.color

            icon: modelData.icon
            onClicked: PowerProfiles.profile = modelData.target
        }
    }
}