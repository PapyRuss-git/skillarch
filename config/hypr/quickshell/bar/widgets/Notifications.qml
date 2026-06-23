import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ClickableModule {
    id: root

    property int count: 0
    property bool dndEnabled: false

    property string iconActive: "\u{f0f3}"
    property string iconDnd: "\u{f1f6}"

    text: dndEnabled
        ? (count > 0 ? " " + iconDnd + " " + count + " " : " " + iconDnd + " ")
        : (count > 0 ? " " + iconActive + " " + count + " " : " " + iconActive + " ")
    textColor: dndEnabled
        ? Theme.warning
        : (count > 0 ? Theme.aqua : Theme.surfaceVariantFg)

    onClicked: togglePanel.startDetached()
    onRightClicked: toggleDnd.running = true

    Process {
        id: togglePanel
        command: ["swaync-client", "-t", "-sw"]
    }

    Process {
        id: toggleDnd
        command: ["swaync-client", "-d", "-sw"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.dndEnabled = this.text.trim() === "true";
                countPoll.running = true;
            }
        }
    }

    Process {
        id: countPoll
        command: ["swaync-client", "-c", "-sw"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var raw = parseInt(this.text.trim());
                root.count = isNaN(raw) ? 0 : raw;
            }
        }
    }

    Process {
        id: dndPoll
        command: ["swaync-client", "-D", "-sw"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.dndEnabled = this.text.trim() === "true"
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            countPoll.running = true;
            dndPoll.running = true;
        }
    }
}
