import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

SliderRow {
    id: root

    icon: {
        if (percent <= 25) return "\u{f00d7}"      // Très faible
        else if (percent <= 50) return "\u{f00d8}" // Faible-moyen
        else if (percent <= 75) return "\u{f00d9}" // Moyen-haut
        else return "\u{f00da}"                     // Très haut
    }
    value: percent / 100.0

    property int percent: 50

    onAdjusted: function(newValue) {
        var pct = Math.round(newValue * 100);
        brightSet.command = ["brightnessctl", "set", pct + "%"];
        brightSet.running = true;
    }

    Process {
        id: brightSet
        command: ["brightnessctl", "set", "50%"]
        stdout: StdioCollector {
            onStreamFinished: brightPoll.running = true
        }
    }

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
}
