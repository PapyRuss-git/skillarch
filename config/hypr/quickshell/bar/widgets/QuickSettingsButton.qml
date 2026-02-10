import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../.."
import "../common"
import "../../services"

Rectangle {
    id: root

    // Screen this button belongs to (set by Bar)
    property var barScreen: null

    // Network state
    property string netStatus: "disconnected"
    property string netIcon: "\u{f092d}"

    // Bluetooth state
    property string btStatus: "off"
    property string btIcon: "\u{f00b2}"

    // VPN state
    property string vpnStatus: "disconnected"
    property string vpnIcon: "\u{f099e}"

    // Mic state
    property var source: Pipewire.defaultAudioSource
    property bool micMuted: source && source.audio ? source.audio.muted : false

    implicitWidth: iconsRow.implicitWidth + 12
    implicitHeight: Theme.barHeight - 8
    radius: Theme.moduleRadius
    color: "transparent"
    border.width: 1
    border.color: mouseArea.containsMouse ? Theme.borderHover : Theme.borderSubtle

    Behavior on border.color { ColorAnimation { duration: 200 } }

    Row {
        id: iconsRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            color: root.netStatus === "disconnected" ? Theme.red : Theme.fgPrimary
            text: root.netIcon
        }
        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            color: root.btStatus === "off" ? Theme.fgDimmed : Theme.fgPrimary
            text: root.btIcon
        }
        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            color: root.vpnStatus === "connected" ? Theme.green : Theme.red
            text: root.vpnIcon
        }
        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            font.bold: true
            color: root.micMuted ? Theme.red : Theme.fgPrimary
            text: root.micMuted ? "\u{f036d}" : "\u{f036c}"
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (GlobalStates.quickSettingsScreen === root.barScreen)
                GlobalStates.quickSettingsScreen = null;
            else
                GlobalStates.quickSettingsScreen = root.barScreen;
        }
    }

    // --- Polling processes ---

    Process {
        id: networkPoll
        command: [Quickshell.shellRoot + "/scripts/network.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.netStatus = data.status || "disconnected";
                    root.netIcon = data.icon || "\u{f092d}";
                } catch (e) {}
            }
        }
    }

    Process {
        id: btPoll
        command: [Quickshell.shellRoot + "/scripts/bluetooth.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.btStatus = data.status || "off";
                    root.btIcon = data.icon || "\u{f00b2}";
                } catch (e) {}
            }
        }
    }

    Process {
        id: vpnPoll
        command: [Quickshell.shellRoot + "/scripts/vpn.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    root.vpnStatus = data.status || "disconnected";
                    root.vpnIcon = data.icon || "\u{f099e}";
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            networkPoll.running = true;
            btPoll.running = true;
            vpnPoll.running = true;
        }
    }
}
