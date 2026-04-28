pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs
import qs.Styles

/**
* Panel window fills the whole screen and is by default not visible.
* It serves as a container for all widget popups and only becomes visible
* and interactable when a popup is opened.
* 
* Pending work:
* [ ] Watch for screen scale or size changes from hyprctl and adapt this
* [ ] Watch for widget popups activated and show master window
* [ ] Add container for widgets
* [ ] Add animations
*/

ShellRoot {
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: panel_group

            // Catch the modelData from Variants
            // Passes on to individual panel windows
            required property var modelData

            // Interactive shell for all widget popups
            PanelWindow {
                id: master_window
                screen: panel_group.modelData

                property bool isVisible: open_widget !== null
                
                // WlrLayershell.namespace: "qs-master"
                color: "transparent"

                exclusionMode: ExclusionMode.Ignore

                implicitHeight: master_window.screen.height
                implicitWidth: master_window.screen.width

                visible: isVisible

                surfaceFormat.opaque: false



                focusable: false

                Connections {
                    target: Hyprland
                    enabled: master_window.open_widget !== null

                    function onRawEvent(event) {
                        if (event.name === "activewindowv2") {
                            master_window.toggleWidgetPopup(master_window.open_widget);
                        }
                    }
                }


                mask: Region {
                    Region { item: flyout_container }
                }

                property Item open_widget: null

                function toggleWidgetPopup(source) {
                    if (!source || !source.flyout) return;

                    // 1. If clicking the SAME widget, start the close sequence
                    if (open_widget === source) {
                        if (flyout_container.item) flyout_container.item.active = false;
                        animate_close_flyout.start();
                        return;
                    }

                    // 2. If clicking a DIFFERENT widget, just update the reference
                    // The Loader stays active, so the 'BaseFlyout' doesn't die; it just moves and swaps content
                    flyout_container.enable_glide = (open_widget !== null); 
                    open_widget = source;
                }

                Loader {
                    id: flyout_container
                    active: master_window.open_widget !== null
                    anchors.top: parent.top
                    anchors.topMargin: DefaultStyle.widgets.size + DefaultStyle.widgets.margin * 2

                    property bool enable_glide: false

                    // AUTOMATIC CENTERING WITH CLAMPING
                    x: if (master_window.open_widget) {
                        var widgetX = master_window.open_widget.mapToItem(null, 0, 0).x + statusbar.margins.left;
                        var centerX = widgetX + (master_window.open_widget.width / 2) - (implicitWidth / 2);
                        
                        // --- CLAMP LOGIC ---
                        var margin = DefaultStyle.widgets.margin;
                        var minX = margin;
                        var maxX = master_window.width - implicitWidth - margin;
                        
                        return Math.max(minX, Math.min(centerX, maxX));
                    } else {
                        return 0;
                    }

                    // THE GLIDE: Any change to 'x' will now slide over 300ms
                    // Only animate x if we're switching between widgets
                    Behavior on x {
                        enabled: flyout_container.enable_glide
                        SpringAnimation { duration: 200; spring: 5.0; damping: 0.375; epsilon: 0.25; }
                    }

                    sourceComponent: master_window.open_widget?.flyout
                }

                Timer {
                    id: animate_close_flyout
                    interval: 250
                    onTriggered: {
                        master_window.open_widget = null;
                    }
                }
            }

            // Status Bar
            // Placing it after the interactive shell (master window) makes it appear
            // on top of the master window
            PanelWindow {
                id: statusbar
                screen: panel_group.modelData

                implicitHeight: DefaultStyle.widgets.size
                // WlrLayershell.layer: WlrLayer.Overlay

                anchors { top: true; left: true; right: true; }
                margins { 
                    top: DefaultStyle.widgets.margin
                    left: DefaultStyle.widgets.margin
                    right: DefaultStyle.widgets.margin
                    bottom: 0
                }
                
                color: "transparent"
                Dock {}
            }

            function delegateWidgetPopup(source) {
                master_window.toggleWidgetPopup(source);
            }

            function dismissPopup() {
                if (!master_window.open_widget) return;
                master_window.toggleWidgetPopup(master_window.open_widget);
            }
        }
    }
}