import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ColumnLayout {
    id: root

    spacing: 6
    Layout.fillWidth: true

    property bool btOn: false
    property var devices: []
    property bool expanded: true

    SectionHeader {
        icon: "\u{f00af}"
        label: "Bluetooth"
        toggleOn: root.btOn
        expandable: true
        expanded: root.expanded
        onToggled: btToggle.running = true
        onExpandToggled: root.expanded = !root.expanded
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: root.expanded ? devicesColumn.childrenRect.height : 0
        height: implicitHeight
        clip: true

        Column {
            id: devicesColumn
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 6

            Repeater {
                model: root.devices

                delegate: DeviceItem {
                    required property var modelData

                    icon: modelData.icon || "\u{f00af}"
                    name: modelData.name || "Unknown"
                    detail: (modelData.connected ? "Connected" : "Disconnected") +
                            (modelData.battery ? "  \u{f0079} " + modelData.battery + "%" : "")
                    badge: modelData.connected ? "\u{f012c}" : ""
                    connected: modelData.connected || false

                    width: devicesColumn.width

                    onClicked: {
                        btToggleDevice.command = [
                            Quickshell.shellDir + "/scripts/bluetooth-toggle-device.sh",
                            modelData.mac
                        ];
                        btToggleDevice.running = true;
                    }
                }
            }
        }
    }

    Process {
        id: btToggle
        command: ["sh", "-c", "bluetoothctl power $(bluetoothctl show | grep -q 'Powered: yes' && echo off || echo on)"]
        stdout: StdioCollector {
            onStreamFinished: {
                btStatusPoll.running = true;
                btDevicesPoll.running = true;
            }
        }
    }

    Process {
        id: btToggleDevice
        command: ["echo"]
        stdout: StdioCollector {
            onStreamFinished: btDevicesPoll.running = true
        }
    }

    Process {
        id: btStatusPoll
        command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.btOn = this.text.trim() === "on"
        }
    }

    Process {
        id: btDevicesPoll
        command: [Quickshell.shellDir + "/scripts/bluetooth-devices.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.devices = JSON.parse(this.text.trim());
                } catch (e) {
                    root.devices = [];
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            btStatusPoll.running = true;
            btDevicesPoll.running = true;
        }
    }
}
