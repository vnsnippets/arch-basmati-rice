pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets

import qs
import qs.Styles
import qs.Utilities
import qs.Types.Components

Clickable {
    id: root
    property string icon: ""
    property string label: ""

    implicitWidth: (label === "") ? Style.widget.width : content.width + Style.widget.padding
    implicitHeight: Style.widget.height

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Style.widget.spacing
        
        // Link this RowLayout's state to the Clickable's state
        state: root.state 

        Text {
            id: icon_text
            text: root.icon

            color: (root.state === root._states.Pressed || root.state === root._states.Hover) ? root.style.text.active : root.style.text.idle
            
            font.pixelSize: Style.fonts.size
            font.family: Style.fonts.icon
            visible: text !== ""

            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            
            // Add Behaviors here for the animation
            Behavior on color { ColorAnimation { duration: Style.animations.duration; easing.type: Easing.OutCubic } }
        }

        Text {
            id: label_text
            text: root.label
            
            color: (root.state === root._states.Pressed || root.state === root._states.Hover) ? root.style.text.active : root.style.text.idle

            font.pixelSize: Style.fonts.size
            font.family: Style.fonts.family
            visible: text !== ""
            
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            
            // Add Behaviors here for the animation
            Behavior on color { ColorAnimation { duration: Style.animations.duration; easing.type: Easing.OutCubic } }
        }
    }
}