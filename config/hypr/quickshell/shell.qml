import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import "bar"
import "watermark"
import "panel"
import "overview"
import "services"

ShellRoot {
    id: root

    // Track Pipewire objects globally so audio properties are accessible
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    // Workspace icons IPC (single handler, shared via GlobalStates)
    property bool wsIconsWanted: false
    property var _focusedMon: Hyprland.focusedMonitor
    property var _activeWsId: _focusedMon && _focusedMon.activeWorkspace
                              ? _focusedMon.activeWorkspace.id : -1

    on_ActiveWsIdChanged: {
        if (wsIconsWanted) {
            wsIconsWanted = false;
            GlobalStates.showWorkspaceIcons = false;
        }
    }

    IpcHandler {
        target: "workspaces"
        function reveal() {
            root.wsIconsWanted = true;
            wsClientsPoll.running = true;
        }
        function dismiss() {
            root.wsIconsWanted = false;
            GlobalStates.showWorkspaceIcons = false;
        }
    }

    Process {
        id: wsClientsPoll
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root.wsIconsWanted) return;
                try {
                    GlobalStates.workspaceWindows = JSON.parse(this.text.trim());
                } catch (e) {
                    GlobalStates.workspaceWindows = [];
                }
                GlobalStates.showWorkspaceIcons = true;
            }
        }
    }

    // Brightness IPC (single handler, notifies all Brightness widgets via counter)
    IpcHandler {
        target: "brightness"
        function refresh() { GlobalStates.brightnessRefreshCount++; }
    }

    // Bar per monitor (Bar handles full/minimal internally)
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }

    // Activate Linux watermark per monitor
    Variants {
        model: Quickshell.screens

        ActivateLinux {
            required property var modelData
            screen: modelData
        }
    }

    // Quick-Settings panel (per monitor overlay)
    QuickSettings {}

    // Workspace overview (per monitor)
    Overview {}
}
