pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

import qs
import qs.Styles
import qs.Utilities
import qs.Types.Components
import qs.Types.States

Clickable {
    id: clickable
    property string icon: ""
    property string label: ""

    implicitWidth: (label === "") ? Style.widget.width : content.width + Style.widget.padding
    implicitHeight: Style.widget.height

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Style.widget.spacing

        readonly property bool isHoveredOrPress: (clickable.state === ClickableState.pressed || clickable.state === ClickableState.hover)

        Text {
            id: icon_text
            text: clickable.icon

            color: (content.isHoveredOrPress) ? clickable.style.text.active : clickable.style.text.idle
            
            font.pixelSize: Style.fonts.size
            font.family: Style.fonts.icon
            visible: text !== ""

            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            
            Behavior on color { ColorAnimation { duration: Style.animations.duration; } }
        }

        Text {
            id: label_text
            text: clickable.label
            
            color: (content.isHoveredOrPress) ? clickable.style.text.active : clickable.style.text.idle

            font.pixelSize: Style.fonts.size
            font.family: Style.fonts.family
            visible: text !== ""
            
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            
            Behavior on color { ColorAnimation { duration: Style.animations.duration; } }
        }
    }
}