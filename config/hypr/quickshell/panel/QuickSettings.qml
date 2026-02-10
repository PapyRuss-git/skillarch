import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
import "../services"
import "common"
import "sections"

Scope {
    id: root

    IpcHandler {
        target: "quicksettings"

        function toggle() {
            if (GlobalStates.quickSettingsScreen !== null)
                GlobalStates.quickSettingsScreen = null;
            else
                GlobalStates.quickSettingsScreen = Quickshell.screens[0];
        }
        function open() {
            GlobalStates.quickSettingsScreen = Quickshell.screens[0];
        }
        function close() {
            GlobalStates.quickSettingsScreen = null;
        }
    }

    // Backdrop per screen — click to close + Escape
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: backdropPanel
            required property var modelData
            screen: modelData

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            visible: GlobalStates.quickSettingsOpen

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "skillarch-qs-backdrop"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: GlobalStates.quickSettingsOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            color: "transparent"

            property Region emptyMask: Region {}
            mask: GlobalStates.quickSettingsOpen ? null : emptyMask

            Item {
                anchors.fill: parent
                focus: GlobalStates.quickSettingsOpen

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.quickSettingsScreen = null;
                        event.accepted = true;
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                z: -1
                onClicked: GlobalStates.quickSettingsScreen = null
            }
        }
    }

    // Content panel — sized, only on clicked screen
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: contentPanel
            required property var modelData
            screen: modelData

            visible: GlobalStates.quickSettingsScreen === modelData

            anchors {
                top: true
                right: true
            }

            margins {
                top: Theme.barHeight + 8
                right: 8
            }

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "skillarch-qs-content"
            WlrLayershell.layer: WlrLayer.Overlay

            implicitWidth: Theme.panelWidth
            implicitHeight: contentColumn.implicitHeight + 24
            Behavior on implicitHeight { enabled: false }
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: Theme.popupRadius
                color: Theme.bgSurface
                border.width: 1
                border.color: Theme.borderLight

                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    VolumeSlider {}
                    BrightnessSlider {}

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.borderSubtle
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        MicToggle { Layout.fillWidth: true }
                        VpnToggle { Layout.fillWidth: true }
                        NightLightToggle { Layout.fillWidth: true }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.borderSubtle
                    }

                    WifiSection {}

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Theme.borderSubtle
                    }

                    BluetoothSection {}
                }
            }
        }
    }
}
