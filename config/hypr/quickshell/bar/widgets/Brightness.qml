import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"
import "../../services"

ClickableModule {
    id: root

    property int percent: 0

    Connections {
        target: GlobalStates
        function onBrightnessRefreshCountChanged() { brightPoll.running = true; }
    }

    text: "\u{f00df}  " + percent + "%"
    textColor: Theme.surfaceFg

    onScrolledUp: brightUp.running = true
    onScrolledDown: brightDown.running = true

    Process {
        id: brightPoll
        command: ["brightnessctl", "info", "-m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(',');
                if (parts.length >= 4)
                    root.percent = parseInt(parts[3].replace('%', ''));
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: brightPoll.running = true
    }

    Process {
        id: brightUp
        command: ["brightnessctl", "set", "+5%"]
        stdout: StdioCollector {
            onStreamFinished: brightPoll.running = true
        }
    }

    Process {
        id: brightDown
        command: ["brightnessctl", "set", "5%-"]
        stdout: StdioCollector {
            onStreamFinished: brightPoll.running = true
        }
    }
}
