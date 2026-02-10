import QtQuick
import "../.."

ModuleLabel {
    id: root

    signal clicked()
    signal rightClicked()
    signal scrolledUp()
    signal scrolledDown()

    hovered: mouseArea.containsMouse

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton)
                root.rightClicked();
            else
                root.clicked();
        }

        onWheel: function(wheel) {
            if (wheel.angleDelta.y > 0)
                root.scrolledUp();
            else
                root.scrolledDown();
        }
    }
}
