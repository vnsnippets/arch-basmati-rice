import QtQuick
import QtQuick.Controls
import QtQuick.Effects

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

                property bool isVisible: active_popup_content !== null

                WlrLayershell.namespace: "qs-master"
                // WlrLayershell.layer: WlrLayer.Overlay

                color: "transparent"

                exclusionMode: ExclusionMode.Ignore
                focusable: false

                implicitHeight: master_window.screen.height
                implicitWidth: master_window.screen.width

                visible: isVisible

                surfaceFormat.opaque: false

                mask: Region {
                    item: statusbar_container
                    intersection: Intersection.Xor
                }

                Item {
                    id: statusbar_container
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: DefaultStyle.widgets.size
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: master_window.isVisible
                    onClicked: {
                        master_window.toggleWidgetPopup(master_window.active_widget);
                    }
                }

                property Item active_widget: null
                property Component active_popup_content: null

                function toggleWidgetPopup(calling_component, content, pos) {
                    if (!calling_component) return;

                    if (active_widget === calling_component) {
                        active_popup_content = active_widget = null;
                        return;
                    }

                    active_widget = calling_component;
                    active_popup_content = content;
                }

                Loader {
                    id: popup_container
                    active: master_window.active_widget !== null
                    anchors.top: statusbar_container.bottom 
                    anchors.topMargin: DefaultStyle.widgets.margin * 2

                    // AUTOMATIC CENTERING BINDING
                    x: if (master_window.active_widget) {
                        var widgetX = master_window.active_widget.mapToItem(null, 0, 0).x + statusbar.margins.left;
                        var centerX = widgetX + (master_window.active_widget.width / 2)- (implicitWidth / 2);
                        return centerX;
                    } else {
                        return 0;
                    }

                    sourceComponent: Component {
                        Rectangle {
                            id: container
                            implicitWidth: popup_content.item?.implicitWidth + DefaultStyle.widgets.padding
                            implicitHeight: popup_content.item?.implicitHeight + DefaultStyle.widgets.padding

                            color: DefaultStyle.color_dark
                            border.color: DefaultStyle.color_slate
                            radius: DefaultStyle.widgets.size / DefaultStyle.widgets.roundness

                            Loader {
                                id: popup_content
                                sourceComponent: master_window.active_popup_content
                                anchors.centerIn: parent
                            }
                        }
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
                WlrLayershell.layer: WlrLayer.Overlay

                anchors { top: true; left: true; right: true; }
                margins { 
                    top: DefaultStyle.widgets.margin
                    left: DefaultStyle.widgets.margin
                    right: DefaultStyle.widgets.margin
                    bottom: 0
                }
                
                color: "transparent"
                StatusBar {}
            }

            function delegateWidgetPopup(calling_component, popup_content) {
                var pos = calling_component.mapToItem(null, 0, 0);
                master_window.toggleWidgetPopup(calling_component, popup_content, pos);
            }
        }
    }
}