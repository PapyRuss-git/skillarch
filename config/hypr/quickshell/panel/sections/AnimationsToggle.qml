import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ToggleRow {
    id: root

    property bool animationsOn: true

    icon: "\u{f04b6}"
    label: "Animations"
    active: animationsOn

    onClicked: toggleCmd.running = true

    Process {
        id: toggleCmd
        command: ["sh", "-c", "hyprctl getoption animations:enabled | awk 'NR==1{print $2}' | grep -q '^1' && hyprctl keyword animations:enabled 0 || hyprctl keyword animations:enabled 1"]
        onExited: function() {
            checkCmd.running = true;
        }
    }

    Process {
        id: checkCmd
        command: ["sh", "-c", "hyprctl getoption animations:enabled | awk 'NR==1{print $2}' | grep -q '^1'"]
        running: true
        onExited: function(code, status) {
            root.animationsOn = (code === 0);
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: checkCmd.running = true
    }
}
