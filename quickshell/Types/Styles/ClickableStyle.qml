import QtQuick

import qs.Styles

QtObject {
    property ColorByState background: ColorByState {
        idle: Style.colors.mantle
        active: Style.colors.mantle
        hover: active
    }

    property ColorByState text: ColorByState {
        idle: Style.colors.text
        active: Style.colors.text
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
    
    property int borderWidth: 1
    property int radius: 16
}