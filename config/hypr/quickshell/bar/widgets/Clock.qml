import QtQuick
import QtQuick.Layouts
import Quickshell
import "../.."

RowLayout {
    id: root

    signal clicked()

    spacing: 6

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    property var currentDate: new Date()

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.currentDate = new Date()
    }

    Text {
        text: {
            var h = clock.hours.toString().padStart(2, '0');
            var m = clock.minutes.toString().padStart(2, '0');
            return h + ":" + m;
        }
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        font.bold: true
        color: Theme.surfaceFg

        MouseArea {
            anchors.fill: parent
            onClicked: root.clicked()
        }
    }

    Text {
        text: Qt.formatDate(root.currentDate, "ddd dd MMM")
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.bold: true
        color: Theme.surfaceVariantFg
        Layout.alignment: Qt.AlignVCenter
    }
}
