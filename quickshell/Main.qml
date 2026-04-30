import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs
import qs.Styles

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Scope {
            id: root
            required property var modelData

            // ── Reserved Space ───────────────────────────────────────────────
            // Registers a fixed window in wayland at the top of the screen.
            // Wayland uses rest of screen for tiling.
            PanelWindow {
                id: barSpace
                screen: modelData

                anchors { top: true; left: true; right: true }
                implicitHeight: Style.dock.height + Style.dock.margin

                color: "transparent"
            }

            PanelWindow {
                id: canvas
                screen: modelData

                property Item open_widget: null
                property bool expanded: open_widget !== null

                // Full screen — anchored to all four edges
                anchors { top: true; left: true; right: true; bottom: true }

                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Top

                color: "transparent"
                surfaceFormat.opaque: false
                focusable: expanded

                // ── Input mask ────────────────────────────────────────────────
                // Collapsed: input is restricted to just the bar strip so that
                //            mouse events elsewhere pass through to windows below.
                // Expanded:  mask is null so the whole canvas can catch clicks
                //            (used for the click-outside-to-close MouseArea).
                // Todo:      only mask the expanded area / popup when expanded
                mask: canvas.expanded ? null : maskRegion
                Region { id: maskRegion; item: dockMask }

                // ── Click-outside-to-close ────────────────────────────────────
                // Sits behind everything (z: 0) and covers the full canvas.
                // Only active when expanded so it doesn't swallow events normally.
                MouseArea {
                    anchors.fill: parent
                    enabled: canvas.expanded
                    visible: canvas.expanded
                    z: 0
                    onClicked: canvas.expanded = false
                }

                Item {
                    id: dockMask
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    implicitHeight: Style.dock.height                    
                }

                // ── Status bar  ───────────────────────────────────────────────
                Dock {
                    id: dock
                    anchors {
                        top:   parent.top
                        left:  parent.left
                        right: parent.right
                    }
                    implicitHeight: Style.dock.height

                    z: 10
                }

                // ── Popup Logic  ───────────────────────────────────────────────
                Connections {
                    target: Hyprland
                    enabled: canvas.open_widget !== null

                    function onRawEvent(event) {
                        if (event.name === "activewindowv2") {
                            canvas.handleWidgetPopup(canvas.open_widget);
                        }
                    }
                }

                Loader {
                    id: flyout_container
                    active: canvas.open_widget !== null
                    anchors.top: parent.top
                    anchors.topMargin: Style.dock.height + Style.dock.margin * 2

                    property bool enable_glide: false

                    // AUTOMATIC CENTERING WITH CLAMPING
                    x: if (canvas.open_widget) {
                        var widgetX = canvas.open_widget.mapToItem(null, 0, 0).x + Style.dock.margin;
                        var centerX = widgetX + (canvas.open_widget.width / 2) - (implicitWidth / 2);
                        
                        // --- CLAMP LOGIC ---
                        var margin = Style.dock.margin;
                        var minX = margin;
                        var maxX = canvas.width - implicitWidth - margin;
                        
                        return Math.max(minX, Math.min(centerX, maxX));
                    } else {
                        return 0;
                    }

                    // THE GLIDE: Any change to 'x' will now slide over 300ms
                    // Only animate x if we're switching between widgets
                    Behavior on x {
                        enabled: flyout_container.enable_glide
                        SpringAnimation { spring: 5.0; damping: 0.375; epsilon: 0.25; }
                    }

                    sourceComponent: canvas.open_widget?.flyout
                }

                Timer {
                    id: animate_close_flyout
                    interval: 250
                    onTriggered: {
                        canvas.open_widget = null;
                    }
                }

                function handleWidgetPopup(source) {
                    if (!source || !source.flyout) return;

                    // 1. If clicking the SAME widget, start the close sequence
                    if (open_widget === source) {
                        if (flyout_container.item) flyout_container.item.active = false;
                        animate_close_flyout.start();
                        return;
                    }

                    // 2. If clicking a DIFFERENT widget, just update the reference
                    // The Loader stays active, so the popup doesn't die; it just moves and swaps content
                    flyout_container.enable_glide = (open_widget !== null); 
                    open_widget = source;
                }
            }
        }
    }
}
