import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

Rectangle {
    id: root

    // --- State ---
    property bool expanded: false

    // --- Data ---
    property int cpuPercent: 0
    property var prevIdle: 0
    property var prevTotal: 0
    property int temp: 0
    property int ramPercent: 0
    property int diskPercent: 0
    property string diskClass: "normal"

    property string worstState: {
        if (temp > 85 || cpuPercent > 90 || ramPercent > 90 || diskClass === "critical")
            return "critical";
        if (temp > 70 || cpuPercent > 75 || ramPercent > 75 || diskClass === "warning")
            return "warning";
        return "normal";
    }

    property color stateColor: worstState === "critical" ? Theme.red
                              : worstState === "warning" ? Theme.orange
                              : Theme.fgDimmed

    implicitWidth: expanded ? label.implicitWidth + 10 : 18
    implicitHeight: Theme.barHeight - 8
    radius: expanded ? Theme.moduleRadius : 9
    color: expanded ? "transparent" : "transparent"
    border.width: expanded ? 1 : 0
    border.color: expanded ? Theme.borderSubtle : "transparent"

    // Pastille (collapsed)
    Rectangle {
        visible: !root.expanded
        width: 8
        height: 8
        radius: 4
        anchors.centerIn: parent
        color: root.stateColor
    }

    // Full text (expanded)
    Text {
        id: label
        visible: root.expanded
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        font.bold: true
        color: root.stateColor

        text: "\u{f0bf2}  " + cpuPercent + "%    " +
              "\u{f0510}  " + temp + "\u00B0    " +
              "\u{f035b}  " + ramPercent + "%    " +
              "\u{f02ca}  " + diskPercent + "%"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    // --- CPU + RAM ---
    FileView {
        id: statFile
        path: "/proc/stat"
        watchChanges: false
    }

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
            statFile.reload();
            var cpuContent = statFile.text();
            if (cpuContent) {
                var firstLine = cpuContent.split('\n')[0];
                var fields = firstLine.split(/\s+/).slice(1).map(Number);
                var idle = fields[3] + (fields[4] || 0);
                var total = 0;
                for (var i = 0; i < fields.length; i++) total += fields[i];
                if (root.prevTotal > 0) {
                    var dTotal = total - root.prevTotal;
                    var dIdle = idle - root.prevIdle;
                    root.cpuPercent = dTotal > 0 ? Math.round(100 * (dTotal - dIdle) / dTotal) : 0;
                }
                root.prevIdle = idle;
                root.prevTotal = total;
            }

            memFile.reload();
            var memContent = memFile.text();
            if (memContent) {
                var lines = memContent.split('\n');
                var memTotal = 0, memAvail = 0;
                for (var j = 0; j < lines.length; j++) {
                    if (lines[j].startsWith("MemTotal:"))
                        memTotal = parseInt(lines[j].split(/\s+/)[1]);
                    else if (lines[j].startsWith("MemAvailable:"))
                        memAvail = parseInt(lines[j].split(/\s+/)[1]);
                }
                if (memTotal > 0)
                    root.ramPercent = Math.round(100 * (memTotal - memAvail) / memTotal);
            }
        }
    }

    // --- Temperature ---
    FileView {
        id: thermalFile
        path: "/sys/class/thermal/thermal_zone0/temp"
        watchChanges: false
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            thermalFile.reload();
            var content = thermalFile.text();
            if (content) {
                var raw = parseInt(content.trim());
                root.temp = raw > 1000 ? Math.round(raw / 1000) : raw;
            }
        }
    }

    // --- Disk ---
    Process {
        id: diskPoll
        command: [Quickshell.shellRoot + "/scripts/disk.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.diskPercent = data.percent || 0;
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
