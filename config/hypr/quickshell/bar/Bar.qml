import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."
import "widgets"

PanelWindow {
    id: root

    // Detect vertical monitor (transform 1 or 3)
    property var hyprMonitor: screen ? Hyprland.monitorFor(screen) : null
    property bool isVertical: {
        if (hyprMonitor && hyprMonitor.lastIpcObject) {
            var t = hyprMonitor.lastIpcObject.transform;
            return t === 1 || t === 3;
        }
        return false;
    }

    anchors {
        top: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Auto
    implicitHeight: Theme.barHeight

    WlrLayershell.namespace: "skillarch-bar"
    WlrLayershell.layer: WlrLayer.Top

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        anchors.bottomMargin: 0
        radius: Theme.barRadius
        color: Theme.barBg
        border.width: 1
        border.color: Theme.borderLight

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            // Left: Clock (time only in minimal, full clock otherwise)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Clock {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.isVertical
                }

                // Minimal: time only
                Text {
                    visible: root.isVertical
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    color: Theme.surfaceFg

                    SystemClock {
                        id: minimalClock
                        precision: SystemClock.Minutes
                    }

                    text: {
                        var h = minimalClock.hours.toString().padStart(2, '0');
                        var m = minimalClock.minutes.toString().padStart(2, '0');
                        return h + ":" + m;
                    }
                }
            }

            // Center: Workspaces
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Workspaces {
                    anchors.centerIn: parent
                    screen: root.screen
                }
            }

            // Right: Full modules or just date (minimal)
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Full bar: all modules
                RowLayout {
                    visible: !root.isVertical
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Volume {}
                    QuickSettingsButton { barScreen: root.screen }
                    Battery {}
                    SystemGroup {}
                    Updates {}
                    Notifications {}
                }
            }
        }
    }
}
