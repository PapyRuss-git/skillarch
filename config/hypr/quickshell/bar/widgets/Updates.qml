import QtQuick
import Quickshell
import Quickshell.Io
import "../.."
import "../common"

ClickableModule {
    id: root

    property int count: 0

    visible: count > 0
    text: "\u{f0397}  " + count
    textColor: Theme.info

    onClicked: updateCmd.startDetached()

    Process {
        id: updateCmd
        command: ["kitty", "--title", "System Update", "sh", "-c", "yay -Syu; echo Done; read"]
    }

    Process {
        id: updatesPoll
        command: [Quickshell.shellDir + "/scripts/updates.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.count = data.count || 0;
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: updatesPoll.running = true
    }
}
