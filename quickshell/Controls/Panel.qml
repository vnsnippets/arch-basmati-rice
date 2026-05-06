import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.Types

Rectangle {
    id: panelRoot
    
    // Internal State
    property bool isOpen: false
    
    color: "white"
    radius: 16
    clip: true

    // Dynamic Sizing: Match the ColumnLayout + margins
    width: componentContainer.implicitWidth
    height: componentContainer.implicitHeight

    // Animations
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