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

        Text {
            id: icon_text
            text: root.icon

            color: (content.isHoveredOrPress) ? root.style.text.active : root.style.text.idle
            
            font.pixelSize: root.fontSize
            font.family: root.iconFont
            visible: text !== ""

            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            
            Behavior on color { ColorAnimation { duration: Style.animations.duration; } }
        }

        Text {
            id: label_text
            text: root.label
            
            color: (content.isHoveredOrPress) ? root.style.text.active : root.style.text.idle

            font.pixelSize: root.fontSize
            font.family: Style.fonts.family
            visible: text !== ""
            
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            
            Behavior on color { ColorAnimation { duration: Style.animations.duration; } }
        }
    }
}