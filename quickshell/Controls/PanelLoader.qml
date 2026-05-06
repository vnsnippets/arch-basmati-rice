import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.Types
import qs.Styles

Loader {
    id: root
    active: activePanel !== null
    
    required property string position
    property Component activePanel: null

    anchors {
        // This pushes the panel down by 40px from the top of the canvas
        top: canvas.top
        
        // Define which side it sticks to based on your 'position' property
        left: position === PanelPosition.left ? canvas.left : undefined
        right: position === PanelPosition.right ? canvas.right : undefined
    }

    y: Style.dock.height

    sourceComponent: activePanel
}