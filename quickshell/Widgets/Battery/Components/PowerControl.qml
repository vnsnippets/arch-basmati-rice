import QtQuick
import QtQuick.Layouts

import Quickshell

import qs
import qs.Styles
import qs.Utilities
import qs.Types.Components

RowLayout {
    Layout.fillWidth: true
    spacing: Style.widget.spacing

    ClickableWithIconAndLabel {
        Layout.fillWidth: true
        icon: "󰌾"
        label: "Lock"
        onClicked: Daemon.execute(["loginctl", "lock-session"])
        style.background.idle: Style.popup.button.background.idle
        style.background.active: Style.popup.button.background.active
    }

    ClickableWithIconAndLabel {
        Layout.fillWidth: true
        icon: "󰒲"
        label: "Sleep"
        onClicked: Daemon.execute(["systemctl", "suspend"])
        style.background.idle: Style.popup.button.background.idle
        style.background.active: Style.popup.button.background.active
    }

    ClickableWithIconAndLabel {
        Layout.fillWidth: true
        icon: "󰑓"
        label: "Reboot"
        onClicked: Daemon.execute(["systemctl", "reboot"])
        style.background.idle: Style.popup.button.background.idle
        style.background.active: Style.popup.button.background.active
    }
    
    ClickableWithIconAndLabel {
        Layout.fillWidth: true
        icon: "󰐥"
        label: "Power"
        onClicked: Daemon.execute(["systemctl", "poweroff"])
        style.background.idle: Style.popup.button.background.idle
        style.background.active: Style.popup.button.background.active
    }
}