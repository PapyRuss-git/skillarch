import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root

    property alias text: label.text
    property alias textColor: label.color
    property bool hovered: false

    implicitWidth: label.implicitWidth + 6
    implicitHeight: Theme.barHeight - 8

    radius: Theme.moduleRadius
    color: "transparent"
    border.width: 1
    border.color: hovered ? Theme.borderHover : Theme.borderSubtle

    Behavior on border.color { ColorAnimation { duration: 200 } }

    Text {
        id: label
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        font.bold: true
        color: Theme.surfaceFg
    }
}
