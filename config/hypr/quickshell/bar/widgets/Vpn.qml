import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ClickableModule {
    id: root

    property string status: "disconnected"
    property string vpnText: "OFF"
    property string icon: "\u{f099e}"

    text: icon + "  " + vpnText
    textColor: status === "connected" ? Theme.primary : Theme.error

    onClicked: vpnToggle.running = true
    onRightClicked: nmEditor.startDetached()

    Process {
        id: vpnToggle
        command: ["sh", "-c", "~/.config/waybar/scripts/vpn-toggle.sh"]
        stdout: StdioCollector {
            onStreamFinished: vpnPoll.running = true
        }
    }

    Process {
        id: nmEditor
        command: ["nm-connection-editor"]
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
                    root.vpnText = data.text || "OFF";
                    root.icon = data.icon || "\u{f099e}";
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
