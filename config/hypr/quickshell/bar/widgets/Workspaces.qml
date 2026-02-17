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

    function appIcon(cls) {
        var c = (cls || "").toLowerCase();
        if (c === "kitty" || c === "alacritty" || c === "foot" || c === "wezterm")
            return "\u{f0489}";      // terminal
        if (c === "firefox" || c === "zen" || c === "chromium" || c === "google-chrome" || c === "brave-browser" || c === "vivaldi")
            return "\u{f0239}";      // web
        if (c === "discord")
            return "\u{f066f}";      // discord
        if (c === "obsidian")
            return "\u{f0219}";      // note
        if (c === "code" || c === "code-oss" || c === "vscodium")
            return "\u{f0a1e}";      // vscode
        if (c === "nautilus" || c === "thunar" || c === "dolphin" || c === "pcmanfm")
            return "\u{f024b}";      // folder
        if (c === "spotify")
            return "\u{f0cc7}";      // music
        if (c === "steam")
            return "\u{f0bae}";      // gamepad
        if (c === "gimp" || c === "inkscape" || c === "krita")
            return "\u{f006e}";      // palette
        if (c === "vlc" || c === "mpv")
            return "\u{f040a}";      // play
        if (c === "thunderbird" || c === "geary")
            return "\u{f01ee}";      // email
        if (c === "slack")
            return "\u{f04b1}";      // slack
        if (c === "telegram-desktop" || c === "telegramdesktop")
            return "\u{f0e97}";      // telegram
        if (c === "signal")
            return "\u{f1507}";      // signal
        if (c === "burpsuite" || c === "wireshark" || c === "ghidra")
            return "\u{f0483}";      // security
        return "\u{f0beb}";          // generic window
    }

    Repeater {
        model: 10

        delegate: Rectangle {
            id: wsButton
            required property int index

            property int wsId: index + 1
            property var hyprMonitor: root.screen ? Hyprland.monitorFor(root.screen) : null
            property bool isActive: {
                if (!hyprMonitor) return false;
                var focused = hyprMonitor.activeWorkspace;
                return focused && focused.id === wsId;
            }
            property bool isOccupied: {
                for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                    var ws = Hyprland.workspaces.values[i];
                    if (ws.id === wsId) return true;
                }
                return false;
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

            visible: isActive || isOccupied
            implicitWidth: wsRow.implicitWidth + 18
            implicitHeight: Theme.barHeight - 8
            radius: 10
            color: "transparent"

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
                    color: wsButton.isActive ? Theme.surfaceFg
                         : wsButton.isOccupied ? Theme.surfaceVariantFg
                         : Theme.outlineVariant
                }

                Repeater {
                    model: GlobalStates.showWorkspaceIcons ? wsButton.wsWindows : []

                    delegate: Text {
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.appIcon(modelData["class"])
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: Theme.surfaceVariantFg
                    }
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
