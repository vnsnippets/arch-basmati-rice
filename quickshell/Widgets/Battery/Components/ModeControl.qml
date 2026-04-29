import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Widgets

Clickable {
    required property var target
    readonly property bool is_active: PowerProfiles.profile === target

    property color color: Style.color_light

    style.background.idle: (is_active) ? color : Style.popup.button.background.idle
    style.text.idle: (is_active) ? Style.color_dark : Style.color_light
    
    style.background.active: color
    style.text.active: Style.color_dark

    onClicked: PowerProfiles.profile = target
}