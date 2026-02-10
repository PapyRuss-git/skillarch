import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root

    property string icon: ""
    property string name: ""
    property string detail: ""
    property string badge: ""
    property bool connected: false

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 44
    radius: 6
    color: mouseArea.containsMouse ? Theme.bgFloat : "transparent"
    border.width: connected ? 2 : 0
    border.color: connected ? Theme.green : "transparent"


    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: 16
            color: Theme.fgSecond
            Layout.preferredWidth: 20
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: root.name
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                color: Theme.fgPrimary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.detail
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.fgDimmed
                visible: detail !== ""
            }
        }

        Text {
            text: root.badge
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.green
            visible: badge !== ""
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
