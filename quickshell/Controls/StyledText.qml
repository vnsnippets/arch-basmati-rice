import QtQuick

import qs.Styles

Text {
    id: root
    color: Style.colors.text
    font.pixelSize: Style.fonts.size
    font.family: Style.fonts.icon
    horizontalAlignment: Text.AlignHCenter
    visible: text !== ""

    Behavior on color { ColorAnimation { duration: Style.animations.duration; } }
}