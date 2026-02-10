import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ToggleRow {
    id: root

    property bool nightlightOn: false

    icon: "\u{f0159}"
    label: "Night"
    active: nightlightOn

    onClicked: toggleCmd.running = true

    Process {
        id: toggleCmd
        command: ["sh", "-c", "pkill -x hyprsunset || hyprsunset >/dev/null 2>&1 &"]
        stdout: StdioCollector {
            onStreamFinished: checkCmd.running = true
        }
    }

    Process {
        id: checkCmd
        command: ["pgrep", "-x", "hyprsunset"]
        running: true
        onExited: function(code, status) {
            root.nightlightOn = (code === 0);
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: checkCmd.running = true
    }
}
