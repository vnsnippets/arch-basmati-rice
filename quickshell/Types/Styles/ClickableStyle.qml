import QtQuick

import qs.Styles

QtObject {
    property ColorByState background: ColorByState {
        idle: Style.color_dark_75
        active: Style.color_dark_75
        hover: active
    }

    property ColorByState text: ColorByState {
        idle: Style.color_light
        active: Style.color_light
        hover: active
    }

    property ColorByState icon: ColorByState {
        idle: text.idle
        active: text.active
        hover: active
    }

    property ColorByState border: ColorByState {
        idle: "transparent"
        active: text.active
        hover: "transparent"
    }
}