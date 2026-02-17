import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ModuleLabel {
    id: root

    property int temp: 0
    property string tempClass: temp > 85 ? "critical" : temp > 70 ? "warning" : "normal"

    text: "\u{f0510}  " + temp + "\u00B0C"  // 󰔐
    textColor: tempClass === "critical" ? Theme.error
             : tempClass === "warning" ? Theme.warning
             : Theme.surfaceFg

    // Blinking animation for critical temps
    SequentialAnimation on opacity {
        running: tempClass === "critical"
        loops: Animation.Infinite
        NumberAnimation { to: 0.4; duration: 500 }
        NumberAnimation { to: 1.0; duration: 500 }
    }

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
}
