import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root

    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 48
        right: 16
    }

    implicitWidth: 280
    implicitHeight: watermarkColumn.implicitHeight + 8

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "skillarch-watermark"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    color: "transparent"

    // Empty mask = all clicks pass through
    mask: Region {}

    ColumnLayout {
        id: watermarkColumn
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: "Activate Linux"
            font.family: Theme.fontFamily
            font.pixelSize: 18
            font.bold: true
            color: Qt.rgba(0.98, 0.98, 0.98, 0.35)
        }

        Text {
            text: "Go to Settings to activate Linux"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            color: Qt.rgba(0.98, 0.98, 0.98, 0.35)
        }
    }
}
