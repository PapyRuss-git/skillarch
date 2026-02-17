import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ToggleRow {
    id: root

    property string status: "disconnected"

    icon: "\u{f099e}"
    label: "VPN"
    active: status === "connected"

    onClicked: vpnToggle.running = true

    Process {
        id: vpnToggle
        command: ["sh", "-c", "~/.config/waybar/scripts/vpn-toggle.sh"]
        stdout: StdioCollector {
            onStreamFinished: vpnPoll.running = true
        }
    }

    Process {
        id: vpnPoll
        command: [Quickshell.shellDir + "/scripts/vpn.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.status = data.status || "disconnected";
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: vpnPoll.running = true
    }
}
