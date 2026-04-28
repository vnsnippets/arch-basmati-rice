import QtQuick
import QtQuick.Layouts

import Quickshell

import qs
import qs.Styles
import qs.Widgets
import qs.Utilities

RowLayout {
    Layout.fillWidth: true
    spacing: DefaultStyle.widgets.spacing

    Clickable { 
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        icon: "󰌾"
        label: "Lock"
        onClicked: Daemon.execute(["loginctl", "lock-session"], () => panel_group.dismissPopup())
    }

    Clickable {
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        icon: "󰒲"
        label: "Sleep"
        onClicked: Daemon.execute(["systemctl", "suspend"], () => panel_group.dismissPopup())
    }

    Clickable {
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        icon: "󰑓"
        label: "Reboot"
        onClicked: Daemon.execute(["systemctl", "reboot"])
    }
    
    Clickable {
        Layout.fillWidth: true
        Layout.preferredWidth: 0
        icon: "󰐥"
        label: "Power"
        onClicked: Daemon.execute(["systemctl", "poweroff"])
    }
}