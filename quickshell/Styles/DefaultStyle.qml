pragma Singleton

import QtQuick

Item {
    readonly property color color_dark: '#1a1d2a'
    readonly property color color_light: "#DDE4FB"
    readonly property color color_slate: "#627386"
    readonly property color color_blue: "#3498db"
    readonly property color color_teal: "#81c8be"
    readonly property color color_green: "#a6d189"
    readonly property color color_yellow: "#e5c890"
    readonly property color color_red: "#e78284"

    readonly property QtObject widgets: QtObject {
        readonly property int size: 40
        readonly property int spacing: 4
        readonly property int margin: 10
        readonly property int padding: 24
        readonly property int border: 1
        readonly property real roundness: 3
    }

    readonly property QtObject animations: QtObject {
        readonly property int duration: 250
    }

    readonly property QtObject fonts: QtObject {
        readonly property int size: 14
        readonly property string family: "Noto Sans"
        readonly property string icon: "Symbols Nerd Font"
    }
}