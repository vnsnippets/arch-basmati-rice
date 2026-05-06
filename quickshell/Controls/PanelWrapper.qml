import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Hyprland

import qs
import qs.Styles

Rectangle {
    id: root

    color: Style.panel.colors.background
    radius: Style.panel.radius
    
    border.width: Style.borderWidth
    border.color: Style.panel.colors.border

    default property alias content: container.data
    // property bool active: false

    implicitWidth: container.width + (Style.panel.padding * 2)
    implicitHeight: container.height + (Style.panel.padding * 2)
    
    clip: true
    transformOrigin: Item.Top

    // Background Animations
    scale: (active) ? 1.0 : 0
    opacity: (active) ? 1.0 : 0

    Behavior on scale { NumberAnimation { duration: Style.animations.duration; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Style.animations.duration } }

    Item {
        id: container
        anchors.centerIn: parent
    }
}