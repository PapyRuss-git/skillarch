import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."
import "../services"

Item {
    id: root

    required property var toplevel
    required property real previewScale
    required property bool onCurrentMonitor

    property real windowX: 0
    property real windowY: 0
    property real windowW: 100
    property real windowH: 100

    x: windowX
    y: windowY
    width: windowW
    height: windowH

    opacity: onCurrentMonitor ? 1.0 : 0.4

    Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
    Behavior on y { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

    // Window capture
    Item {
        id: captureContainer
        anchors.fill: parent
        clip: true

        ScreencopyView {
            id: screencopy
            anchors.fill: parent
            captureSource: GlobalStates.overviewOpen ? root.toplevel : null
            live: true
        }

        // Fallback when no capture available
        Rectangle {
            anchors.fill: parent
            color: Theme.bgSurface
            visible: !screencopy.hasContent
            radius: Theme.windowRounding * root.previewScale

            // App icon in center
            Image {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) * 0.4
                height: width
                source: {
                    if (!root.toplevel) return "";
                    var appId = root.toplevel.appId || "";
                    if (appId === "") return "";
                    var entry = DesktopEntries.heuristicLookup(appId);
                    return entry ? entry.icon : "";
                }
                sourceSize.width: 64
                sourceSize.height: 64
            }
        }
    }

    // Border overlay
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: Theme.windowRounding * root.previewScale
        border.width: mouseArea.containsMouse ? 2 : 1
        border.color: mouseArea.containsMouse ? Theme.borderHover : Theme.borderSubtle
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        ToolTip.visible: containsMouse && root.toplevel
        ToolTip.delay: 300
        ToolTip.text: {
            if (!root.toplevel) return "";
            var title = root.toplevel.title || "";
            var appClass = root.toplevel.appId || "";
            return title + "\n" + appClass;
        }
    }
}
