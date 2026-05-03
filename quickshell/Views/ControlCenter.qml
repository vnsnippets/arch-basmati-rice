import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Styles
import qs.Types

Rectangle {
    id: root
    property bool active: false
    
    // Using Layout.alignment instead of anchors fixes the warning
    // Layout.alignment: Qt.AlignHCenter
    anchors.horizontalCenter: parent.horizontalCenter
    
    implicitWidth: Style.widgets.width
    implicitHeight: Style.widgets.height
    
    border.width: 1
    border.color: Style.dashboard.colors.border
    color: Style.dashboard.colors.background
    radius: Style.dashboard.radius
    clip: true

    states: [
        State {
            name: "expanded"
            when: root.active
            PropertyChanges {
                target: root
                // Using explicit width/height here overrides implicit values
                width: Style.dashboard.width
                height: Style.dashboard.height
            }
        }
    ]

    transitions: Transition {
        NumberAnimation {
            properties: "width, height"
            duration: 500
            easing.type: Easing.OutExpo
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent 
        spacing: 0 // Set to 0 so the clickable area is flush at the top

        // This is your "Handle" - the only part that toggles the expansion
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.widgets.height
            WrapperMouseArea {
                id: toggleHandle
                anchors.centerIn: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.active = !root.active

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: ""
                    rotation: root.active ? 180 : 0
                    color: Style.dashboard.colors.text
                    
                    Behavior on rotation { 
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
                    }
                }
            }
        }

        // The Actual Dashboard Content
        Item {
            id: dashboardBody
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.active
            opacity: root.active ? 1 : 0
            
            Behavior on opacity { NumberAnimation { duration: 250 } }

            Text {
                anchors.centerIn: parent
                text: "Dashboard Content (Clicking here won't close me)"
                color: Style.dashboard.colors.text
            }
        }
    }
}