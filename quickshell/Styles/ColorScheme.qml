import QtQuick

QtObject {
    property ClickableStyle background: ClickableStyle {
        idle: DefaultStyle.color_dark
        active: DefaultStyle.color_dark
    }

    property ClickableStyle text: ClickableStyle {
        idle: DefaultStyle.color_light
        active: DefaultStyle.color_light
    }

    property ClickableStyle icon: ClickableStyle {
        idle: text.idle
        active: text.active
    }

    property ClickableStyle border: ClickableStyle {
        idle: background.idle
        active: background.active
    }
}