import QtQuick

import qs.Styles

Text {
    property bool active: false

    id: root
    color: (active) ? Style.clickable.text.active : Style.clickable.text.idle
    font.pixelSize: Style.fonts.size
    font.family: Style.fonts.icon
    horizontalAlignment: Text.AlignHCenter
    visible: text !== ""

    Behavior on color { ColorAnimation { duration: Style.animations.duration; } }
}