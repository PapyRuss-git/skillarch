import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../.."
import "../common"
import "../../services"

RowLayout {
    id: root

    property var screen
    spacing: 2

    function pushLookupCandidate(list, candidate) {
        var value = (candidate || "").toString().trim();
        if (value === "") return;
        if (list.indexOf(value) === -1) list.push(value);
    }

    function addLookupVariants(list, candidate) {
        var value = (candidate || "").toString().trim();
        if (value === "") return;

        root.pushLookupCandidate(list, value);

        var lower = value.toLowerCase();
        root.pushLookupCandidate(list, lower);

        if (lower.length > 8 && lower.slice(lower.length - 8) === ".desktop")
            root.pushLookupCandidate(list, lower.slice(0, lower.length - 8));
    }

    function desktopEntryForWindow(windowData) {
        if (!windowData) return null;

        var candidates = [];
        root.addLookupVariants(candidates, windowData["class"]);
        root.addLookupVariants(candidates, windowData.initialClass);

        for (var i = 0; i < candidates.length; i++) {
            var entry = DesktopEntries.heuristicLookup(candidates[i]);
            if (entry && entry.icon) return entry;
        }

        return null;
    }

    function workspaceAppIcons(windows) {
        var icons = [];
        var seen = {};

        for (var i = 0; i < windows.length; i++) {
            var entry = root.desktopEntryForWindow(windows[i]);
            if (!entry || !entry.icon) continue;

            var iconSource = Quickshell.iconPath(entry.icon, "application-x-executable");
            if (!iconSource) continue;

            var key = entry.id || entry.icon;
            if (seen[key]) continue;

            seen[key] = true;
            icons.push({
                key: key,
                source: iconSource
            });
        }

        return icons;
    }

    Repeater {
        model: 10

        delegate: Rectangle {
            id: wsButton
            required property int index

            property int wsId: index + 1
            property var hyprMonitor: root.screen ? Hyprland.monitorFor(root.screen) : null
            property var workspaceData: {
                for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                    var ws = Hyprland.workspaces.values[i];
                    if (ws.id === wsId) return ws;
                }
                return null;
            }
            property bool isHostedOnMonitor: {
                if (!hyprMonitor || !workspaceData) return false;

                var workspaceMonitorId = workspaceData.monitorID;
                if (workspaceMonitorId === undefined)
                    workspaceMonitorId = workspaceData.monitorId;
                if (workspaceMonitorId === undefined && workspaceData.lastIpcObject)
                    workspaceMonitorId = workspaceData.lastIpcObject.monitorID;
                if (workspaceMonitorId !== undefined && workspaceMonitorId === hyprMonitor.id)
                    return true;

                var workspaceMonitorName = workspaceData.monitor;
                if ((workspaceMonitorName === undefined || workspaceMonitorName === null) &&
                    workspaceData.lastIpcObject)
                    workspaceMonitorName = workspaceData.lastIpcObject.monitor;

                var hyprMonitorName = hyprMonitor.name;
                if ((hyprMonitorName === undefined || hyprMonitorName === null) &&
                    hyprMonitor.lastIpcObject)
                    hyprMonitorName = hyprMonitor.lastIpcObject.name;

                return !!hyprMonitorName && workspaceMonitorName === hyprMonitorName;
            }
            property bool isActive: {
                var focusedMonitor = Hyprland.focusedMonitor;
                if (!focusedMonitor) return false;
                var focusedWorkspace = focusedMonitor.activeWorkspace;
                return focusedWorkspace && focusedWorkspace.id === wsId;
            }
            property var wsWindows: {
                if (!GlobalStates.showWorkspaceIcons) return [];
                var result = [];
                var wl = GlobalStates.workspaceWindows;
                for (var i = 0; i < wl.length; i++) {
                    var w = wl[i];
                    if (w.workspace && w.workspace.id === wsId &&
                        !w.hidden && w.mapped !== false)
                        result.push(w);
                }
                return result;
            }
            property var wsAppIcons: root.workspaceAppIcons(wsWindows)
            property var visibleAppIcons: wsAppIcons.slice(0, 3)
            property int hiddenAppCount: Math.max(0, wsAppIcons.length - visibleAppIcons.length)

            visible: isHostedOnMonitor
            implicitWidth: wsRow.implicitWidth + 18
            implicitHeight: Theme.barHeight - 8
            radius: 10
            color: wsButton.isActive ? Theme.primaryContainer
                   : Theme.surfaceDim

            border.width: isActive ? 2 : 1
            border.color: isActive ? Theme.primary
                        : mouseArea.containsMouse ? Theme.withAlpha(Theme.primary, 0.5)
                        : Theme.borderSubtle

            Row {
                id: wsRow
                anchors.centerIn: parent
                spacing: 3

                Text {
                    id: wsText
                    anchors.verticalCenter: parent.verticalCenter
                    text: wsButton.wsId
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    color: wsButton.isActive ? Theme.primaryContainerFg
                         : Theme.surfaceFg
                }

                Repeater {
                    model: GlobalStates.showWorkspaceIcons ? wsButton.visibleAppIcons : []

                    delegate: Image {
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14
                        height: 14
                        source: modelData.source
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 28
                        sourceSize.height: 28
                        asynchronous: true
                        mipmap: true
                    }
                }

                Text {
                    visible: GlobalStates.showWorkspaceIcons && wsButton.hiddenAppCount > 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: "+" + wsButton.hiddenAppCount
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: wsButton.isActive ? Theme.primaryContainerFg
                         : Theme.surfaceVariantFg
                }

                Text {
                    visible: GlobalStates.showWorkspaceIcons
                             && wsButton.wsWindows.length > 0
                             && wsButton.wsAppIcons.length === 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: "?"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: wsButton.isActive ? Theme.primaryContainerFg
                         : Theme.surfaceVariantFg
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + wsButton.wsId)
            }
        }
    }
}
