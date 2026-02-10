import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."
import "../services"

Scope {
    id: root

    // IPC handler for toggle/open/close
    IpcHandler {
        target: "overview"

        function toggle() {
            if (!GlobalStates.overviewOpen) {
                HyprlandData._doRefresh();
            }
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
        function open() {
            HyprlandData._doRefresh();
            GlobalStates.overviewOpen = true;
        }
        function close() {
            GlobalStates.overviewOpen = false;
        }
    }

    // One overlay per screen
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: overviewPanel
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            visible: GlobalStates.overviewOpen

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "skillarch-overview"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: GlobalStates.overviewOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            color: Qt.rgba(0, 0, 0, 0.5)

            // When open: no mask (receive all input). When closed: empty mask (click-through).
            property Region emptyMask: Region {}
            mask: GlobalStates.overviewOpen ? null : emptyMask

            // Keyboard navigation
            Item {
                id: keyHandler
                anchors.fill: parent
                focus: GlobalStates.overviewOpen

                Keys.onPressed: function(event) {
                    switch (event.key) {
                    case Qt.Key_Escape:
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        GlobalStates.overviewOpen = false;
                        event.accepted = true;
                        break;

                    case Qt.Key_Left:
                    case Qt.Key_H:
                        navigateWorkspace(-1, 0);
                        event.accepted = true;
                        break;
                    case Qt.Key_Right:
                    case Qt.Key_L:
                        navigateWorkspace(1, 0);
                        event.accepted = true;
                        break;
                    case Qt.Key_Up:
                    case Qt.Key_K:
                        navigateWorkspace(0, -1);
                        event.accepted = true;
                        break;
                    case Qt.Key_Down:
                    case Qt.Key_J:
                        navigateWorkspace(0, 1);
                        event.accepted = true;
                        break;

                    case Qt.Key_1: case Qt.Key_2: case Qt.Key_3:
                    case Qt.Key_4: case Qt.Key_5: case Qt.Key_6:
                    case Qt.Key_7: case Qt.Key_8: case Qt.Key_9:
                        var wsId = event.key - Qt.Key_0;
                        Hyprland.dispatch("workspace " + wsId);
                        GlobalStates.overviewOpen = false;
                        event.accepted = true;
                        break;
                    case Qt.Key_0:
                        Hyprland.dispatch("workspace 10");
                        GlobalStates.overviewOpen = false;
                        event.accepted = true;
                        break;

                    case Qt.Key_Tab:
                        navigateWorkspace(1, 0);
                        event.accepted = true;
                        break;
                    }
                }

                function navigateWorkspace(dx, dy) {
                    var mon = overviewPanel.screen ? Hyprland.monitorFor(overviewPanel.screen) : null;
                    if (!mon || !mon.activeWorkspace) return;
                    var current = mon.activeWorkspace.id;
                    var col = (current - 1) % Theme.overviewColumns;
                    var row = Math.floor((current - 1) / Theme.overviewColumns);
                    var newCol = Math.max(0, Math.min(Theme.overviewColumns - 1, col + dx));
                    var newRow = Math.max(0, Math.min(Theme.overviewRows - 1, row + dy));
                    var newWsId = newRow * Theme.overviewColumns + newCol + 1;
                    if (newWsId !== current) {
                        Hyprland.dispatch("workspace " + newWsId);
                    }
                }
            }

            // Overview content (always loaded, visibility controlled by parent PanelWindow)
            OverviewWidget {
                anchors.centerIn: parent
                screen: overviewPanel.screen
            }

            // Click on backdrop to close
            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: GlobalStates.overviewOpen = false
            }
        }
    }
}
