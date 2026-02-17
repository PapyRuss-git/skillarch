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

    property bool wifiOn: true
    property var networks: []
    property bool expanded: true

    SectionHeader {
        icon: "\u{f0928}"
        label: "WiFi"
        toggleOn: root.wifiOn
        expandable: true
        expanded: root.expanded
        onToggled: wifiToggle.running = true
        onExpandToggled: root.expanded = !root.expanded
    }

    Repeater {
        model: root.expanded ? root.networks : []

        delegate: DeviceItem {
            required property var modelData

            icon: modelData.icon || "\u{f0928}"
            name: modelData.ssid || "Unknown"
            detail: (modelData.signal || 0) + "%" +
                    (modelData.security && modelData.security !== "--" && modelData.security !== "Open"
                        ? "  \u{f0332}  " + modelData.security
                        : "  Open")
            badge: modelData.connected ? "\u{f012c}" : (modelData.known ? "\u{f006f}" : "")
            connected: modelData.connected || false

            Layout.fillWidth: true

            onClicked: {
                wifiConnect.command = [
                    Quickshell.shellDir + "/scripts/wifi-connect.sh",
                    modelData.ssid
                ];
                wifiConnect.running = true;
            }
        }
    }

    Process {
        id: wifiToggle
        command: ["sh", "-c", "nmcli radio wifi $(nmcli radio wifi | grep -q enabled && echo off || echo on)"]
        stdout: StdioCollector {
            onStreamFinished: {
                wifiListPoll.running = true;
                wifiStatusPoll.running = true;
            }
        }
    }

    Process {
        id: wifiConnect
        command: ["echo"]
        stdout: StdioCollector {
            onStreamFinished: wifiListPoll.running = true
        }
    }

    Process {
        id: wifiListPoll
        command: [Quickshell.shellDir + "/scripts/wifi-list.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.networks = JSON.parse(this.text.trim());
                } catch (e) {
                    root.networks = [];
                }
            }
        }
    }

    Process {
        id: wifiStatusPoll
        command: ["nmcli", "radio", "wifi"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.wifiOn = this.text.trim() === "enabled"
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            wifiListPoll.running = true;
            wifiStatusPoll.running = true;
        }
    }
}
