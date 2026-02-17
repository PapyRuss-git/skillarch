import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool active: false
    property real iconScale: 1.0

    signal clicked()

    implicitWidth: 90
    implicitHeight: 36
    radius: 8
    color: active ? Theme.withAlpha(Theme.primary, 0.15) : Theme.surfaceContainer
    border.width: 1
    border.color: active ? Theme.withAlpha(Theme.primary, 0.3) : "transparent"


    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: 16 * root.iconScale
            color: root.active ? Theme.primary : Theme.surfaceVariantFg
        }

        Text {
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            font.bold: true
            color: root.active ? Theme.surfaceFg : Theme.surfaceVariantFg
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
        onContainsMouseChanged: {
            if (containsMouse)
                parent.opacity = 0.85;
            else
                parent.opacity = 1.0;
        }
    }
}
