import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ClickableModule {
    id: root

    property string status: "off"
    property string btText: ""
    property string icon: "\u{f00b2}"

    text: icon + (btText !== "" ? " " + btText : "")
    textColor: status === "off" ? Theme.fgDimmed : Theme.fgPrimary

    onRightClicked: gnomeBt.startDetached()

    Process {
        id: gnomeBt
        command: ["env", "XDG_CURRENT_DESKTOP=GNOME", "gnome-control-center", "bluetooth"]
    }

    Process {
        id: btPoll
        command: [Quickshell.shellRoot + "/scripts/bluetooth.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.status = data.status || "off";
                    root.btText = data.text || "";
                    root.icon = data.icon || "\u{f00b2}";
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: btPoll.running = true
    }
}
