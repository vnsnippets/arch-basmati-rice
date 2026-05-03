import QtQuick
import Quickshell
import Quickshell.Widgets

import qs.Styles
import qs.Types

PopupWindow {
    id: root
    property bool expanded: false

    anchor.window: canvas
    anchor.rect.x: parentWindow.width / 2 - width / 2
    anchor.rect.y: Style.dashboard.margin

    visible: true
    color: "transparent"

    WrapperMouseArea {
        id: toggleWrapper
        width: 40
        height: 40
        hoverEnabled: true

        // This is the component that will drop
        Clickable {            
            // Final position when dropped
            readonly property int targetY: 0
            
            // Formula Logic:
            // Visible: opacity 1, y = targetY
            // Hidden:  opacity 0, y = targetY - 21 (since your formula was -21x + 1)
            opacity: toggleWrapper.containsMouse || root.expanded ? 1 : 0
            y: toggleWrapper.containsMouse || root.expanded ? targetY : targetY - 21

            // The animation logic
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

            onClicked: root.expanded = !root.expanded
        }
    }
}