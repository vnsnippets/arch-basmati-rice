import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles

RowLayout {
    spacing: 10
    Rectangle {
        id: root
        
        width: 72
        height: 72

        readonly property var arc_center: width/2
        readonly property var arc_radius: width/2 - width/10
        readonly property var arc_stroke: width/18

        radius: width / 2 // Makes the background a circle

        // Faint background color for the entire container circle
        color: Qt.rgba(1, 1, 1, 0.05) 
        
        // Optional border for a visible outer ring
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1

        // Note: UPower.displayDevice.percentage is 0 to 1
        readonly property real battery_percent: UPower.displayDevice.percentage * 100
        readonly property bool battery_is_charging: UPower.displayDevice.state === 1 || UPower.displayDevice.state === 5

        property real animated_percentage: 0

        readonly property color arc_color: {
            if (battery_is_charging) {
                return DefaultStyle.color_yellow
            } else if (battery_percent <= Context.battery.critical_threshold) {
                return DefaultStyle.color_red
            } else if (battery_percent <= Context.battery.warning_threshold) {
                return DefaultStyle.color_yellow
            } else {
                return DefaultStyle.color_green
            }
        }

        NumberAnimation on animated_percentage {
            from: 0
            to: root.battery_percent.toFixed(0) // Uses the battery_percent property (0-100)
            duration: 800
            easing.type: Easing.OutCubic 
        }

        NumberAnimation on scale {
            from: 0.8; to: 1; duration: 1000;
            easing.type: Easing.OutCubic 
        }

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 6 // High samples for smooth rounded edges on CachyOS

            scale: 1 / root.scale 
            
            // 1. THE TRACK (Faint background)
            ShapePath {
                fillColor: "transparent"
                strokeColor: Qt.rgba(1, 1, 1, 0.1) // White with 10% opacity
                strokeWidth: root.arc_stroke/2

                PathAngleArc {
                    centerX: root.arc_center; centerY: root.arc_center;
                    radiusX: root.arc_radius; radiusY: root.arc_radius;
                    startAngle: 0
                    sweepAngle: 360 // Full circle track
                }
            }

            // 2. THE ANIMATED ARC
            ShapePath {
                fillColor: "transparent"
                strokeColor: root.arc_color
                strokeWidth: root.arc_stroke
                
                // This property rounds the start and end of the arc
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: root.arc_center; centerY: root.arc_center;
                    radiusX: root.arc_radius; radiusY: root.arc_radius;
                    startAngle: -90
                    sweepAngle: 360 * (root.animated_percentage / 100)
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.animated_percentage.toFixed(0) + "%"
            font.pixelSize: 16
            font.bold: true
            color: DefaultStyle.color_light
        }
    }

    ColumnLayout {
        spacing: 4
        Text {
            text: `AC: ${root.battery_is_charging ? "Connected" : "Disconnected"}`
            font.pixelSize: 16
            color: DefaultStyle.color_light
        }

        Text {
            text: "7 Hours 15 Minutes"
            font.pixelSize: 16
            color: DefaultStyle.color_light
            opacity: 0.6
        }
    }
}