import QtQuick
import Quickshell
import Quickshell.Hyprland

import qs
import qs.Styles

Rectangle {
    id: root
    default property alias content: content_container.data
    property bool active: false

    readonly property int animation_duration: 300

    color: DefaultStyle.color_overlay
    radius: DefaultStyle.popup.radius
    border.width: 1
    border.color:DefaultStyle.color_slate

    implicitWidth: content_container.childrenRect.width + (DefaultStyle.widgets.padding * 2)
    implicitHeight: content_container.childrenRect.height + (DefaultStyle.widgets.padding * 2)
    
    clip: true

    // Background Animations
    scale: (active) ? 1.0 : 0.5
    opacity: (active) ? 1.0 : 0

    Behavior on scale { NumberAnimation { duration: animation_duration; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: animation_duration } }

    Item {
        id: content_container
        anchors.centerIn: parent

        opacity: root.active ? 1 : 0
        //scale: 1 / root.scale  // Enable for counter scaling

        y: root.active ? 0 : 10 
        Behavior on y { NumberAnimation { duration: animation_duration; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: animation_duration } }
    }

    Component.onCompleted: {
        active = true;
    }
}