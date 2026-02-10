import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."
import "../services"

Item {
    id: root

    required property var screen
    property var hyprMonitor: screen ? Hyprland.monitorFor(screen) : null

    // Grid config from theme
    property int gridRows: Theme.overviewRows
    property int gridCols: Theme.overviewColumns
    property real previewScale: Theme.overviewScale

    // Monitor pixel dimensions (already accounts for transform in Quickshell)
    property real monitorWidth: hyprMonitor ? hyprMonitor.width : 1920
    property real monitorHeight: hyprMonitor ? hyprMonitor.height : 1080

    // Reserved space (bar at top)
    property real reservedTop: Theme.barHeight

    // Scaled workspace size
    property real wsWidth: monitorWidth * previewScale
    property real wsHeight: (monitorHeight - reservedTop) * previewScale
    property real wsSpacing: 12
    property real wsPadding: 24

    // Total content size
    property real contentWidth: gridCols * wsWidth + (gridCols - 1) * wsSpacing + wsPadding * 2
    property real contentHeight: gridRows * wsHeight + (gridRows - 1) * wsSpacing + wsPadding * 2

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    // Background
    Rectangle {
        anchors.fill: parent
        radius: Theme.overviewRounding
        color: Theme.bgDim
        border.width: 1
        border.color: Theme.borderSubtle
    }

    // Grid of workspaces using QtQuick Grid
    Grid {
        id: wsGrid
        anchors.centerIn: parent
        columns: root.gridCols
        rows: root.gridRows
        spacing: root.wsSpacing

        Repeater {
            model: root.gridRows * root.gridCols

            delegate: Item {
                id: wsDelegate
                required property int index
                property int wsId: index + 1
                property bool isActive: {
                    if (!root.hyprMonitor) return false;
                    var focused = root.hyprMonitor.activeWorkspace;
                    return focused && focused.id === wsId;
                }

                width: root.wsWidth
                height: root.wsHeight

                // Workspace background
                Rectangle {
                    id: wsBg
                    anchors.fill: parent
                    radius: Theme.overviewRounding - 4
                    color: dropArea.containsDrag ? Qt.lighter(Theme.bgBase, 1.2) : Theme.bgBase
                    border.width: isActive ? 2 : (wsMouseArea.containsMouse ? 1 : 0)
                    border.color: isActive ? Theme.green : Theme.borderHover

                    Behavior on border.width {
                        NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                    }

                    // Workspace number
                    Text {
                        anchors.centerIn: parent
                        text: wsDelegate.wsId
                        font.family: Theme.fontFamily
                        font.pixelSize: root.wsHeight * 0.4
                        font.bold: true
                        color: Qt.rgba(
                            Theme.fgDimmed.r,
                            Theme.fgDimmed.g,
                            Theme.fgDimmed.b,
                            0.15
                        )
                    }

                    // Windows in this workspace
                    Repeater {
                        id: windowRepeater
                        model: {
                            var windows = [];
                            for (var i = 0; i < HyprlandData.windowList.length; i++) {
                                var w = HyprlandData.windowList[i];
                                if (w.workspace && w.workspace.id === wsDelegate.wsId &&
                                    !w.hidden && w.mapped !== false) {
                                    windows.push(w);
                                }
                            }
                            windows.sort(function(a, b) {
                                if (a.pinned !== b.pinned) return a.pinned ? -1 : 1;
                                if (a.floating !== b.floating) return a.floating ? -1 : 1;
                                return (a.focusHistoryID || 0) - (b.focusHistoryID || 0);
                            });
                            return windows;
                        }

                        delegate: Item {
                            id: windowItem
                            required property var modelData
                            required property int index

                            property var toplevelMatch: {
                                if (!modelData) return null;
                                var cls = modelData["class"] || "";
                                var title = modelData.title || "";
                                for (var i = 0; i < ToplevelManager.toplevels.values.length; i++) {
                                    var tl = ToplevelManager.toplevels.values[i];
                                    if (!tl) continue;
                                    // Match by appId + title
                                    if (tl.appId === cls && tl.title === title) return tl;
                                }
                                // Fallback: match by appId only
                                for (var j = 0; j < ToplevelManager.toplevels.values.length; j++) {
                                    var tl2 = ToplevelManager.toplevels.values[j];
                                    if (tl2 && tl2.appId === cls) return tl2;
                                }
                                return null;
                            }

                            property bool onCurrentMonitor: {
                                if (!root.hyprMonitor || !modelData.monitor) return true;
                                return modelData.monitor === root.hyprMonitor.id;
                            }

                            // Position window within the scaled workspace
                            property real winX: {
                                if (!modelData.at) return 0;
                                var monX = 0;
                                for (var i = 0; i < HyprlandData.monitors.length; i++) {
                                    if (HyprlandData.monitors[i].id === modelData.monitor) {
                                        monX = HyprlandData.monitors[i].x || 0;
                                        break;
                                    }
                                }
                                return (modelData.at[0] - monX) * root.previewScale;
                            }
                            property real winY: {
                                if (!modelData.at) return 0;
                                var monY = 0;
                                for (var i = 0; i < HyprlandData.monitors.length; i++) {
                                    if (HyprlandData.monitors[i].id === modelData.monitor) {
                                        monY = HyprlandData.monitors[i].y || 0;
                                        break;
                                    }
                                }
                                return (modelData.at[1] - monY - root.reservedTop) * root.previewScale;
                            }
                            property real winW: modelData.size ? modelData.size[0] * root.previewScale : 50
                            property real winH: modelData.size ? modelData.size[1] * root.previewScale : 50

                            x: winX
                            y: winY
                            width: winW
                            height: winH

                            // Dragging state
                            property bool isDragging: dragMouseArea.drag.active

                            Drag.active: isDragging
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2

                            // Window preview
                            OverviewWindow {
                                id: overviewWindow
                                anchors.fill: parent
                                toplevel: windowItem.toplevelMatch
                                previewScale: root.previewScale
                                onCurrentMonitor: windowItem.onCurrentMonitor
                            }

                            MouseArea {
                                id: dragMouseArea
                                anchors.fill: parent
                                drag.target: parent
                                hoverEnabled: true

                                onClicked: {
                                    Hyprland.dispatch("focuswindow address:" + modelData.address);
                                    GlobalStates.overviewOpen = false;
                                }

                                onReleased: {
                                    if (windowItem.Drag.drop() === Qt.IgnoreAction) {
                                        windowItem.x = windowItem.winX;
                                        windowItem.y = windowItem.winY;
                                    }
                                }
                            }
                        }
                    }

                    // Click on empty workspace area
                    MouseArea {
                        id: wsMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        z: -1
                        onClicked: {
                            Hyprland.dispatch("workspace " + wsDelegate.wsId);
                            GlobalStates.overviewOpen = false;
                        }
                    }

                    // Drop area for drag & drop
                    DropArea {
                        id: dropArea
                        anchors.fill: parent

                        onDropped: function(drop) {
                            var source = drop.source;
                            if (source && source.modelData && source.modelData.address) {
                                Hyprland.dispatch("movetoworkspacesilent " + wsDelegate.wsId + ",address:" + source.modelData.address);
                            }
                        }
                    }
                }
            }
        }
    }
}
