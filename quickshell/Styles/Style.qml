pragma Singleton

import QtQuick


Item {
    property QtObject colors: QtObject {
        property color rosewater: "#f5e0dc"
        property color flamingo: "#f2cdcd"
        property color pink: "#f5c2e7"
        property color mauve: "#cba6f7"
        property color red: "#f38ba8"
        property color maroon: "#eba0ac"
        property color peach: "#fab387"
        property color yellow: "#f9e2af"
        property color green: "#a6e3a1"
        property color teal: "#94e2d5"
        property color sky: "#89dceb"
        property color sapphire: "#74c7ec"
        property color blue: "#89b4fa"
        property color lavender: "#b4befe"

        property color text: "#cdd6f4"
        property color subtext1: "#bac2de"
        property color subtext0: "#a6adc8"
        property color overlay2: "#9399b2"
        property color overlay1: "#7f849c"
        property color overlay0: "#6c7086"
        property color surface2: "#585b70"
        property color surface1: "#45475a"
        property color surface0: "#313244"
        property color base: "#1e1e2e"
        property color mantle: "#181825"
        property color crust: "#11111b"
    }

    readonly property QtObject dock: QtObject {
        readonly property int spacing: 4
        readonly property int margin: 8
        readonly property int height: 40
    }

    readonly property QtObject widget: QtObject {
        readonly property int width: 40
        readonly property int height: 40
        readonly property int spacing: 4
        readonly property int padding: 24
        readonly property int radius: 16

        readonly property QtObject colors: QtObject {
            readonly property color background: colors.mantle
            readonly property color border: "transparent"
            readonly property color text: colors.text
        }
    }

    readonly property QtObject popup: QtObject {
        readonly property real radius: 12
        readonly property real spacing: 20
        readonly property color background: colors.mantle

        readonly property QtObject button: QtObject {
            readonly property QtObject background: QtObject {
                readonly property color idle: colors.base
                readonly property color active: colors.mantle
            }
        }
        readonly property QtObject animations: QtObject {
            readonly property int duration: 300
        }
    }

    readonly property QtObject dashboard: QtObject {
        readonly property int margin: 10
        readonly property int width: 1920/2
        readonly property int height: 1200/2
        readonly property int spacing: 8
        readonly property int radius: 32

        readonly property int rows: 10
        readonly property int columns: 16

        readonly property QtObject colors: QtObject {
            readonly property color background: colors.mantle
            readonly property color border: colors.text
            readonly property color text: colors.text
        }

        readonly property QtObject cell: QtObject {
            readonly property int size: 56
            readonly property int radius: 16
            readonly property int margin: 16
        }
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