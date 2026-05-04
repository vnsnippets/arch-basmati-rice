import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.Styles
import qs.Types.Components

Rectangle {
    id: root
    readonly property int animDuration: 500 

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: Style.dock.margin
    
    // Dynamic Dimensions
    width: canvas.dashboardOpen ? Style.dashboard.width : Style.widget.width
    height: canvas.dashboardOpen ? Style.dashboard.height : Style.widget.height
    
    color: Style.dashboard.colors.background
    radius: canvas.dashboardOpen ? Style.dashboard.radius : Style.border_radius // More rounded when it's a button
    clip: true
    
    // Animate dimension changes
    Behavior on width { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuint } }
    Behavior on height { NumberAnimation { duration: animDuration; easing.type: Easing.OutQuint } }
    Behavior on radius { NumberAnimation { duration: animDuration } }

    ColumnLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Style.widget.height

            // Click to toggle
            MouseArea {
                anchors.fill: parent
                onClicked: canvas.dashboardOpen = !canvas.dashboardOpen
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }

            Text {
                id: label
                anchors.centerIn: parent
                text: ""
                color: Style.dashboard.colors.text

                font.pixelSize: Style.fonts.size
                font.family: Style.fonts.family

                // opacity: canvas.dashboardOpen ? 0 : 1
                // visible: opacity > 0
                // Behavior on opacity { NumberAnimation { duration: animDuration } }

                rotation: canvas.dashboardOpen ? 180 : 0
                Behavior on rotation { 
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
                }
            }
        }

        // 3. Lazy Loaded Content
        Loader {
            id: contentLoader
            // anchors.fill: parent
            // anchors.margins: 20
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // UNLOADS content when minimized, LOADS when opened
            active: canvas.dashboardOpen 
            
            sourceComponent: ColumnLayout {
                spacing: 20

                // Header with close button
                // RowLayout {
                //     Layout.fillWidth: true
                //     Text {
                //         text: "Dashboard"
                //         color: "white"
                //         font.bold: true; font.pointSize: 14
                //     }
                //     Item { Layout.fillWidth: true }
                //     Rectangle {
                //         width: 30; height: 30; radius: 15; color: "#333"
                //         Text { anchors.centerIn: parent; text: "×"; color: "white"; font.pointSize: 16 }
                //         MouseArea {
                //             anchors.fill: parent
                //             onClicked: canvas.dashboardOpen = false
                //             hoverEnabled: true
                //             cursorShape: Qt.PointingHandCursor
                //         }
                //     }
                // }

                // // Tabs
                // Row {
                //     Layout.alignment: Qt.AlignHCenter
                //     spacing: 10
                //     Repeater {
                //         model: ["Home", "Settings", "Info"]
                //         delegate: Rectangle {
                //             width: 100; height: 35; radius: 6
                //             color: canvas.currentTab === index ? "#3d5afe" : "#333"
                //             Text { anchors.centerIn: parent; text: modelData; color: "white" }
                //             MouseArea {
                //                 anchors.fill: parent
                //                 onClicked: canvas.currentTab = index
                //             }
                //         }
                //     }
                // }

                // // Sliding Panes
                // ListView {
                //     Layout.fillWidth: true
                //     Layout.fillHeight: true
                //     clip: true
                //     orientation: ListView.Horizontal
                //     snapMode: ListView.SnapOneItem
                //     currentIndex: canvas.currentTab
                //     model: 3
                //     delegate: Item {
                //         width: ListView.view.width
                //         height: ListView.view.height
                //         Text {
                //             anchors.centerIn: parent
                //             text: "Tab Content " + (index + 1)
                //             color: "#aaa"; font.pointSize: 20
                //         }
                //     }
                //     onCurrentIndexChanged: canvas.currentTab = currentIndex
                // }
            }
        }
    }
}