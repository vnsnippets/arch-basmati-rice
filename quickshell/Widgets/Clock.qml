import QtQuick
import Quickshell

import qs
import qs.Utilities

Base {
    id: container

    property string format: "yyyy-MM-dd HH:mm"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    label: Qt.formatDateTime(clock.date, format)

    // property string tooltipformat: "D dd MMMyyyy-MM-dd HH:mm:ss"

    // function ordinalDay(day) {
    //     if (day % 10 === 1 && day % 100 !== 11) return day + "st";
    //     if (day % 10 === 2 && day % 100 !== 12) return day + "nd";
    //     if (day % 10 === 3 && day % 100 !== 13) return day + "rd";
    //     return day + "th";
    // }

    // tooltip: Qt.formatDate(new Date(), "MMMM") + " " + ordinalDay(new Date()) + ", " + Qt.formatDate(new Date(), "yyyy");
}