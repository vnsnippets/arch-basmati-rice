import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.Styles
import qs.Types.Styles
import qs.Types.Components
import qs.Controls

Rectangle {
    id: root
    readonly property int animDuration: 400 

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: Style.dock.margin
    
    // Dynamic Dimensions
    width: masterLayout.width
    height: masterLayout.height
    
    color: Style.dashboard.colors.background
    radius: canvas.dashboardOpen ? Style.dashboard.radius : Style.border_radius
    clip: true
    
    // Animate dimension changes
    Behavior on width { NumberAnimation { duration: animDuration; easing.type: Easing.OutExpo } }
    Behavior on height { NumberAnimation { duration: animDuration; easing.type: Easing.OutExpo } }
    Behavior on radius { NumberAnimation { duration: animDuration } }

    ColumnLayout {
        id: masterLayout

        WrapperMouseArea {
            // Layout.fillWidth: true
            Layout.preferredHeight: Style.widget.height
            Layout.preferredWidth: clockContainer.width
            Layout.alignment: Qt.AlignHCenter

            onClicked: canvas.dashboardOpen = !canvas.dashboardOpen
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor


            Item {
                id: clockContainer
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                implicitWidth: label.implicitWidth + Style.widget.padding
                implicitHeight: label.implicitHeight

                Text {
                    id: label
                    anchors.centerIn: parent

                    text: ""
                    
                    color: Style.dashboard.colors.text

                    font.pixelSize: Style.fonts.size
                    font.family: Style.fonts.family

                    renderType: Text.QtRendering // Often smoother for animations than NativeRendering
                    antialiasing: true 
                    horizontalAlignment: Text.AlignHCenter
                    
                    // This helps the text engine handle sub-pixel positions better
                    transformOrigin: Item.Center

                    // opacity: canvas.dashboardOpen ? 0 : 1
                    // visible: opacity > 0
                    // Behavior on opacity { NumberAnimation { duration: animDuration } }

                    rotation: canvas.dashboardOpen ? 180 : 0
                    Behavior on rotation { 
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
                    }
                }
            }
        }

        // 3. Lazy Loaded Content
        Loader {
            id: contentLoader
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.leftMargin: Style.dashboard.spacing * 2
            Layout.rightMargin: Style.dashboard.spacing * 2
            Layout.bottomMargin: Style.dashboard.spacing * 2
            
            // UNLOADS content when minimized, LOADS when opened
            active: canvas.dashboardOpen
            visible: canvas.dashboardOpen
            
            sourceComponent: GridLayout {
                id: dashboardGrid
                rows: Style.dashboard.rows
                columns: Style.dashboard.columns
                rowSpacing: Style.dashboard.spacing
                columnSpacing: Style.dashboard.spacing
                flow: GridLayout.TopToBottom
                
                ClickableWithIconAndLabel {
                    Layout.row: 0
                    Layout.column: 4

                    style: ClickableStyle {
                        background.idle: Style.color_slate
                    }

                    implicitWidth: 56
                    implicitHeight: 56
                    fontSize: 20

                    icon: ""
                }

                ClickableWithIconAndLabel {
                    Layout.row: 1
                    Layout.column: 4

                    style: ClickableStyle {
                        background.idle: Style.color_slate
                    }

                    implicitWidth: 56
                    implicitHeight: 56
                    fontSize: 20

                    icon: "󰂯"
                }

                ClickableWithIconAndLabel {
                    Layout.row: 2
                    Layout.column: 4

                    style: ClickableStyle {
                        background.idle: Style.color_slate
                    }

                    implicitWidth: 56
                    implicitHeight: 56
                    fontSize: 20

                    icon: ""
                }

                ClickableWithIconAndLabel {
                    Layout.row: 3
                    Layout.column: 4

                    style: ClickableStyle {
                        background.idle: Style.color_slate
                    }

                    implicitWidth: 56
                    implicitHeight: 56
                    fontSize: 20

                    icon: "󰂠"
                }

                ClickableWithIconAndLabel {
                    Layout.row: 4
                    Layout.column: 4

                    style: ClickableStyle {
                        background.idle: Style.color_slate
                    }

                    implicitWidth: 56
                    implicitHeight: 56
                    fontSize: 20

                    icon: "󰈈"
                }

                DashboardItem {
                    Layout.row: 0
                    Layout.column: 2

                    implicitHeight: 56
                    implicitWidth: brightness.width + Style.dashboard.cell.margin * 2

                    BrightnessControl { id: brightness; anchors.centerIn: parent; }
                }

                DashboardItem {
                    Layout.row: 0
                    Layout.column: 1

                    implicitHeight: 56
                    implicitWidth: volume.width + Style.dashboard.cell.margin * 2

                    VolumeControl { id: volume; anchors.centerIn: parent; }
                }
            }
        }
    }
}