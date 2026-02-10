import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool active: false

    signal clicked()

    implicitWidth: 90
    implicitHeight: 36
    radius: 8
    color: active ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.15) : Theme.bgFloat
    border.width: 1
    border.color: active ? Qt.rgba(Theme.green.r, Theme.green.g, Theme.green.b, 0.3) : "transparent"


    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: 16
            color: root.active ? Theme.green : Theme.fgSecond
        }

        Text {
            text: root.label
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTiny
            font.bold: true
            color: root.active ? Theme.fgPrimary : Theme.fgSecond
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
