import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ModuleLabel {
    id: root

    property int percent: 0
    property var prevIdle: 0
    property var prevTotal: 0

    text: "\u{f0bf2}  " + percent + "%"  // 󰻠
    textColor: Theme.blue

    FileView {
        id: statFile
        path: "/proc/stat"
        watchChanges: false
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            var content = statFile.text();
            if (!content) return;

            var firstLine = content.split('\n')[0];
            var fields = firstLine.split(/\s+/).slice(1).map(Number);

            var idle = fields[3] + (fields[4] || 0); // idle + iowait
            var total = 0;
            for (var i = 0; i < fields.length; i++) total += fields[i];

            if (root.prevTotal > 0) {
                var dTotal = total - root.prevTotal;
                var dIdle = idle - root.prevIdle;
                root.percent = dTotal > 0 ? Math.round(100 * (dTotal - dIdle) / dTotal) : 0;
            }

            root.prevIdle = idle;
            root.prevTotal = total;
        }
    }
}
