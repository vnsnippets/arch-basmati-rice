pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.Types
import qs.Styles
import qs.Utilities

Loader {
    id: root

    property string position: ""

    y: Style.dock.height

    property Component content: null

    active: content !== null

    readonly property var stopwatch: Stopwatch.create(root, false, false);
    function showPanelAsync(position, component) {
        root.anchors.left = position === PanelPosition.left ? parent.left : undefined
        root.anchors.right = position === PanelPosition.right ? parent.right : undefined
        root.position = position

        // --- Cold Start ---
        if (content === null) {
            content = component;
            return;
        }

        // --- Same component clicked ---
        if (content && content.url === component.url) {
            item.active = !item.active;
            if (item.active) stopwatch.stop()
            else {
                stopwatch.begin(Style.panel.animation, () => {
                     if (item && !item.active) content = null
                })
            }
            return;
        }

        // --- Parallel Swap Logic ---
        item.swap(component);
    }

    sourceComponent: Rectangle {
        color: Style.panel.colors.background
        radius: Style.panel.radius
        border.width: Style.borderWidth
        border.color: Style.panel.colors.border

        implicitWidth: container.width + (Style.panel.padding * 2)
        implicitHeight: container.height + (Style.panel.padding * 2)
        Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        
        clip: true
        
        // Dynamically map the position to the transformOrigin
        transformOrigin: {
            switch(root.position) {
                case PanelPosition.top:    return Item.Top;
                case PanelPosition.bottom: return Item.Bottom;
                case PanelPosition.left:   return Item.TopLeft;
                case PanelPosition.right:  return Item.TopRight;
                default:                   return Item.Center;
            }
        }

        property bool active: false

        // Background Animations
        scale: (active) ? 1.0 : 0
        opacity: (active) ? 1.0 : 0
        Behavior on scale { NumberAnimation { duration: Style.panel.animation; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Style.panel.animation } }

        function swap(component) {
            // Start fade out
            contentFade.enabled = true;
            container.opacity = 0;
            
            // Wait for fade out to finish, then swap and fade in
            stopwatch.begin(Style.panel.animation/2, () => {
                root.content = component;
                container.opacity = 1;
            });
        }

        Loader { 
            id: container
            anchors.centerIn: parent
            sourceComponent: root.content
            
            // Animation for the content swap
            opacity: 1
            Behavior on opacity { 
                id: contentFade
                enabled: false // Only enable during cross-swaps
                NumberAnimation { duration: Style.panel.animation / 2 } 
            }
        }

        Component.onCompleted: active = true
    }
}