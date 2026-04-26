import QtQuick
import Quickshell
import Quickshell.Services.UPower

import qs
import qs.Styles
import qs.Utilities

Base {
    id: container

    // Icons
    readonly property var icon_map: ({
        [PowerProfile.PowerSaver]:  "",
        [PowerProfile.Balanced]:    "",
        [PowerProfile.Performance]: ""
    })

    property color color_powersave: null
    property color color_balanced:  null
    property color color_performance: null

    readonly property var color_map: ({
        [PowerProfile.PowerSaver]:  color_powersave,
        [PowerProfile.Balanced]:    color_balanced,
        [PowerProfile.Performance]: color_performance
    })

    // Bind directly to the service
    property var current_profile: PowerProfiles.profile

    // Live bindings: these re‑evaluate whenever current_profile changes
    icon: icon_map[current_profile]
    style.text.idle: color_map[current_profile]

    // Rotate profiles on click
    onClicked: {
        switch (current_profile) {
        case PowerProfile.PowerSaver:
            PowerProfiles.profile = PowerProfile.Balanced
            break
        case PowerProfile.Balanced:
            PowerProfiles.profile = PowerProfiles.hasPerformanceProfile
                ? PowerProfile.Performance
                : PowerProfile.PowerSaver
            break
        case PowerProfile.Performance:
            PowerProfiles.profile = PowerProfile.PowerSaver
            break
        }
    }
}
