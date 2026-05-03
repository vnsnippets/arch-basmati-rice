import QtQuick
import Quickshell

import qs
import qs.Types
import qs.Styles

Clickable {
    id: widget
    property bool active: false

    implicitWidth: Style.widgets.width

    Text {
        id: icon
        text: ""
        anchors.centerIn: parent
        color: (widget.state === widget._states.Pressed || widget.state === widget._states.Hover) ? widget.style.text.active : widget.style.text.idle
        
        transformOrigin: Item.Center 
        rotation: widget.active ? 180 : 0

        font.pixelSize: Style.fonts.size
        font.family: Style.fonts.icon
        
        // Add Behaviors here for the animation
        Behavior on color { ColorAnimation { duration: Style.animations.duration; easing.type: Easing.OutCubic } }

        Behavior on rotation { 
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
        }
    }

    onClicked: () => {
        widget.active = !widget.active
    }
}