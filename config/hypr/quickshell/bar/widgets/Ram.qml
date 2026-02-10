import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ModuleLabel {
    id: root

    property int percent: 0

    text: "\u{f035b}  " + percent + "%"  // 󰍛
    textColor: Theme.purple

    FileView {
        id: memFile
        path: "/proc/meminfo"
        watchChanges: false
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            memFile.reload();
            var content = memFile.text();
            if (!content) return;

            var lines = content.split('\n');
            var total = 0, available = 0;

            for (var i = 0; i < lines.length; i++) {
                if (lines[i].startsWith("MemTotal:"))
                    total = parseInt(lines[i].split(/\s+/)[1]);
                else if (lines[i].startsWith("MemAvailable:"))
                    available = parseInt(lines[i].split(/\s+/)[1]);
            }

            if (total > 0)
                root.percent = Math.round(100 * (total - available) / total);
        }
    }
}
