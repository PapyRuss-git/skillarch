pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

QtObject {
    id: root

    property var windowList: []
    property var windowByAddress: ({})
    property var addresses: []
    property var monitors: []
    property var workspaces: []
    property var workspaceById: ({})
    property var activeWorkspace: ({})

    // Only refresh when overview is open (avoids constant process spawning)
    property var _refreshTimer: Timer {
        interval: 150
        onTriggered: root._doRefresh()
    }

    function refresh() {
        _refreshTimer.restart();
    }

    function _doRefresh() {
        if (!clientsProc.running) clientsProc.running = true;
        if (!monitorsProc.running) monitorsProc.running = true;
        if (!workspacesProc.running) workspacesProc.running = true;
        if (!activeWsProc.running) activeWsProc.running = true;
    }

    property var _conn: Connections {
        target: Hyprland
        function onRawEvent() {
            if (GlobalStates.overviewOpen) root.refresh();
        }
    }

    property var clientsProc: Process {
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(this.text.trim());
                    root.windowList = parsed;
                    var byAddr = {};
                    var addrs = [];
                    for (var i = 0; i < parsed.length; i++) {
                        var addr = parsed[i].address;
                        byAddr[addr] = parsed[i];
                        addrs.push(addr);
                    }
                    root.windowByAddress = byAddr;
                    root.addresses = addrs;
                } catch (e) {}
            }
        }
    }

    property var monitorsProc: Process {
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.monitors = JSON.parse(this.text.trim()); } catch (e) {}
            }
        }
    }

    property var workspacesProc: Process {
        command: ["hyprctl", "workspaces", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var parsed = JSON.parse(this.text.trim());
                    root.workspaces = parsed;
                    var byId = {};
                    for (var i = 0; i < parsed.length; i++) {
                        byId[parsed[i].id] = parsed[i];
                    }
                    root.workspaceById = byId;
                } catch (e) {}
            }
        }
    }

    property var activeWsProc: Process {
        command: ["hyprctl", "activeworkspace", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.activeWorkspace = JSON.parse(this.text.trim()); } catch (e) {}
            }
        }
    }
}
