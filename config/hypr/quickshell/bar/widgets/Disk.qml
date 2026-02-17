import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ModuleLabel {
    id: root

    property int percent: 0
    property string diskClass: "normal"

    text: "\u{f02ca}  " + percent + "%"
    textColor: diskClass === "critical" ? Theme.error
             : diskClass === "warning" ? Theme.warning
             : Theme.surfaceFg

    Process {
        id: diskPoll
        command: [Quickshell.shellDir + "/scripts/disk.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.percent = data.percent || 0;
                    root.diskClass = data["class"] || "normal";
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: diskPoll.running = true
    }
}
