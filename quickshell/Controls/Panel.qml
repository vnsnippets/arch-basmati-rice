import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.Types

Rectangle {
    id: panelRoot
    
    // Internal State
    property bool isOpen: false
    property string currentDirection: ""
    property int travelDistance: 50 // How far it slides
    
    color: "transparent"
    radius: 16
    clip: true

    property real offset: isOpen ? 0 : travelDistance
    
    // Ensure the panel stays within screen bounds based on direction
    anchors {
        left: currentDirection === PanelDirection.left ? parent.left : undefined
        right: currentDirection === PanelDirection.right ? parent.right : undefined
        top: currentDirection === PanelDirection.bottom ? undefined : parent.top
        bottom: currentDirection === PanelDirection.bottom ? parent.bottom : undefined
        
        // Center the panel on the cross-axis
        verticalCenter: (currentDirection === PanelDirection.left || currentDirection === PanelDirection.right) ? parent.verticalCenter : undefined
        horizontalCenter: (currentDirection === PanelDirection.top || currentDirection === PanelDirection.bottom) ? parent.horizontalCenter : undefined
        
        margins: 20
    }

    // Dynamic Sizing: Match the ColumnLayout + margins
    width: componentContainer.implicitWidth
    height: componentContainer.implicitHeight

    // Animations
    Behavior on offset { NumberAnimation { duration: 400; easing.type: Easing.OutQuint } }
    Behavior on opacity { NumberAnimation { duration: 300 } }
    Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
    
    opacity: isOpen ? 1 : 0
    scale: isOpen ? 1 : 0.95
    
    Loader {
        active: isOpen
        ColumnLayout {
            // This container holds the dynamically injected components
            id: componentContainer
            anchors.fill: parent
            spacing: 20
        }
    }

    // The requested load function
    function load(direction, ...components) {
        // 1. Set direction
        currentDirection = direction;
        
        // 2. Clear existing children in the layout
        for (var i = componentContainer.children.length - 1; i >= 0; i--) {
            componentContainer.children[i].destroy();
        }
        
        // 3. Load new components
        components.forEach(comp => {
            if (comp instanceof Component) {
                comp.createObject(componentContainer, {
                    "Layout.fillWidth": true
                });
            }
        });
        
        // 4. Show the panel
        isOpen = true;
    }

    function close() {
        isOpen = false;
    }
}