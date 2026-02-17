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
    color: mouseArea.containsMouse ? Theme.surfaceContainer : "transparent"
    border.width: connected ? 2 : 0
    border.color: connected ? Theme.primary : "transparent"


    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: 16
            color: Theme.surfaceVariantFg
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
                color: Theme.surfaceFg
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.detail
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTiny
                color: Theme.outlineVariant
                visible: detail !== ""
            }
        }

        Text {
            text: root.badge
            font.family: Theme.fontFamily
            font.pixelSize: 14
            color: Theme.primary
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
