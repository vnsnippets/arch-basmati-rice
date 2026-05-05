pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

import qs
import qs.Types
import qs.Styles
import qs.Controls
import qs.Utilities

Clickable {
    id: root
    property string icon: ""
    property string label: ""

    property int fontSize: Style.fonts.size
    property string iconFont: Style.fonts.icon

    implicitWidth: (label === "") ? Style.widget.width : content.width + Style.widget.padding
    implicitHeight: Style.widget.height

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Style.widget.spacing

        readonly property bool isHoveredOrPress: (root.state === ClickableState.pressed || root.state === ClickableState.hover)

        StyledText {
            id: icon_text
            text: root.icon
            color: (content.isHoveredOrPress) ? root.style.text.active : root.style.text.idle
            
            font.pixelSize: root.fontSize
            font.family: root.iconFont
        }

        StyledText {
            id: label_text
            text: root.label            
            color: (content.isHoveredOrPress) ? root.style.text.active : root.style.text.idle

            font.pixelSize: root.fontSize
            font.family: Style.fonts.family
        }
    }
}