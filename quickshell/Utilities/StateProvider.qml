pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

import qs
import qs.Services

Singleton {
    id: dataprovider
    
    property QtObject caffeine_widget: QtObject {
        property var prevent_lock_process: null
    }

    property QtObject network_widget: QtObject {
        property var scan_with_stopwatch: null
    }
}