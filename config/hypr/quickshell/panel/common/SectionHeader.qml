import QtQuick
import QtQuick.Layouts
import "../.."

RowLayout {
    id: root

    property alias label: headerLabel.text
    property alias icon: headerIcon.text
    property bool toggleOn: false
    property bool showToggle: true
    property bool expandable: false
    property bool expanded: true

    signal toggled()
    signal expandToggled()

    spacing: 8
    Layout.fillWidth: true

    Text {
        id: headerIcon
        font.family: Theme.fontFamily
        font.pixelSize: 16
        color: Theme.surfaceVariantFg
    }

    Text {
        id: headerLabel
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.bold: true
        color: Theme.surfaceVariantFg
        Layout.fillWidth: true

        MouseArea {
            anchors.fill: parent
            enabled: root.expandable
            cursorShape: root.expandable ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.expandToggled()
        }
    }

    Text {
        visible: root.expandable
        text: "\u{f0140}"
        rotation: root.expanded ? 0 : -90
        font.family: Theme.fontFamily
        font.pixelSize: 14
        color: Theme.outlineVariant

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expandToggled()
        }
    }

    Rectangle {
        id: toggleTrack
        visible: root.showToggle
        width: 40
        height: 22
        radius: 11
        color: root.toggleOn ? Theme.primary : Theme.surfaceContainer

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }


        Rectangle {
            id: toggleThumb
            width: 16
            height: 16
            radius: 8
            y: 3
            x: root.toggleOn ? parent.width - width - 3 : 3
            color: root.toggleOn ? Theme.surfaceDim : Theme.outlineVariant

            Behavior on x {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 140
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }
    }
}
