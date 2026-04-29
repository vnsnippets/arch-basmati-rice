import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Utilities

RowLayout {
    id: root
    spacing: 10

    required property bool enable_monitoring

    readonly property real battery_percent: UPower.displayDevice.percentage * 100
    readonly property bool battery_is_charging: UPower.displayDevice.state === 1 || UPower.displayDevice.state === 5

    property string runtime_label: enable_monitoring ? "Calculating..." : "Monitoring is disabled."

    Rectangle {
        id: arc_root
        
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

        property real animated_percentage: 0

        readonly property color arc_color: {
            if (root.battery_is_charging) {
                return Style.color_yellow
            } else if (root.battery_percent <= Context.battery.critical_threshold) {
                return Style.color_red
            } else if (root.battery_percent <= Context.battery.warning_threshold) {
                return Style.color_yellow
            } else {
                return Style.color_green
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

            scale: 1 / arc_root.scale 
            
            // 1. THE TRACK (Faint background)
            ShapePath {
                fillColor: "transparent"
                strokeColor: Qt.rgba(1, 1, 1, 0.1) // White with 10% opacity
                strokeWidth: arc_root.arc_stroke/2

                PathAngleArc {
                    centerX: arc_root.arc_center; centerY: arc_root.arc_center;
                    radiusX: arc_root.arc_radius; radiusY: arc_root.arc_radius;
                    startAngle: 0
                    sweepAngle: 360 // Full circle track
                }
            }

            // 2. THE ANIMATED ARC
            ShapePath {
                fillColor: "transparent"
                strokeColor: arc_root.arc_color
                strokeWidth: arc_root.arc_stroke
                
                // This property rounds the start and end of the arc
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: arc_root.arc_center; centerY: arc_root.arc_center;
                    radiusX: arc_root.arc_radius; radiusY: arc_root.arc_radius;
                    startAngle: -90
                    sweepAngle: 360 * (arc_root.animated_percentage / 100)
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: arc_root.animated_percentage.toFixed(0) + "%"
            font.pixelSize: 16
            font.bold: true
            color: Style.color_light
        }
    }

    ColumnLayout {
        spacing: 4
        Text {
            text: `AC: ${root.battery_is_charging ? "Connected" : "Disconnected"}`
            font.pixelSize: 16
            color: Style.color_light
        }

        Text {
            text: (root.battery_is_charging) ? "Charging" : runtime_label
            font.pixelSize: 16
            color: Style.color_light
            opacity: 0.6
        }
    }

    Timer {
        id: monitoring_timer
        interval: 10000
        repeat: true
        onTriggered: Daemon.execute(["sh", "-c", "upower -i $(upower -e | grep BAT) | grep 'time to' | awk '{print $4, $5}'"], (e) => {
            calculateBatteryLife(e?.output);
        })
    }

    Component.onCompleted: Daemon.execute(["sh", "-c", "upower -i $(upower -e | grep BAT) | grep 'time to' | awk '{print $4, $5}'"], (e) => {
        calculateBatteryLife(e?.output);
        if (enable_monitoring) monitoring_timer.start();
    })

    function calculateBatteryLife(e) {
        if (e && e.length > 0) {
            // e is expected to be something like "4.1 hours"
            let parts = e.trim().split(" ");
            let totalHours = parseFloat(parts[0]);

            if (!isNaN(totalHours)) {
                let hours = Math.floor(totalHours);
                // Convert the decimal remainder into minutes
                let minutes = Math.round((totalHours - hours) * 60);

                // Handle cases where rounding might result in 60 minutes
                if (minutes === 60) {
                    hours += 1;
                    minutes = 0;
                }

                const htext = `${hours} ${hours === 1 ? "Hour" : "Hours"}`
                const mtext = (minutes > 0) ? `${minutes} ${minutes === 1 ? "Minute" : "Minutes"}` : ""
                root.runtime_label = `${htext} ${mtext}`;
            } else {
                root.runtime_label = e.trim();
            }
        } else {
            root.runtime_label = "Calculating...";
        }
    }
}