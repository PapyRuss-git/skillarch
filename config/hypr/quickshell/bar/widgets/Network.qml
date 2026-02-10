import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ClickableModule {
    id: root

    property string status: "disconnected"
    property string ssid: ""
    property string icon: "\u{f092d}"

    text: status === "connected" ? icon + "  " + ssid : " " + icon + " "
    textColor: status === "disconnected" ? Theme.bgDim : Theme.fgPrimary

    border.color: status === "disconnected" ? Theme.red : (hovered ? Theme.borderHover : Theme.borderSubtle)
    color: status === "disconnected" ? Theme.red : "transparent"

    onRightClicked: gnomeWifi.startDetached()

    Process {
        id: gnomeWifi
        command: ["env", "XDG_CURRENT_DESKTOP=GNOME", "gnome-control-center", "wifi"]
    }

    Process {
        id: networkPoll
        command: [Quickshell.shellRoot + "/scripts/network.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.status = data.status || "disconnected";
                    root.ssid = data.ssid || "";
                    root.icon = data.icon || "\u{f092d}";
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: networkPoll.running = true
    }
}
