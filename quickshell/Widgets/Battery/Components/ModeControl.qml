import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Widgets

Clickable {
    required property var target
    readonly property bool is_active: PowerProfiles.profile === target

    property color color: DefaultStyle.color_light

    style.background.idle: (is_active) ? color : DefaultStyle.color_dark
    style.text.idle: (is_active) ? DefaultStyle.color_dark : DefaultStyle.color_light
    
    style.background.active: color
    style.text.active: DefaultStyle.color_dark

    onClicked: PowerProfiles.profile = target
}