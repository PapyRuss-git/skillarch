import QtQuick
import QtQuick.Layouts
import "../.."

RowLayout {
    id: root

    property string icon: ""
    property real value: 0.0
    property int displayPercent: Math.round(value * 100)

    signal adjusted(real newValue)

    spacing: 10
    Layout.fillWidth: true

    Text {
        text: root.icon
        font.family: Theme.fontFamily
        font.pixelSize: 18
        color: Theme.surfaceVariantFg
        Layout.preferredWidth: 24
    }

    // Custom slider using pure MouseArea (works reliably in PanelWindow layer-shell)
    Item {
        id: sliderItem
        Layout.fillWidth: true
        implicitHeight: 24

        // Track background
        Rectangle {
            id: track
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            radius: 3
            color: Theme.surfaceContainer

            // Fill
            Rectangle {
                width: root.value * parent.width
                height: parent.height
                radius: 3
                color: Theme.primary
            }
        }

        // Handle
        Rectangle {
            id: handle
            x: root.value * (sliderItem.width - width)
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            radius: 8
            color: dragArea.pressed ? Theme.surfaceFg : Theme.surfaceVariantFg
            border.width: 1
            border.color: Theme.borderLight
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            hoverEnabled: true

            function valueFromMouse(mouseX) {
                var v = mouseX / sliderItem.width;
                return Math.max(0.0, Math.min(1.0, v));
            }

            onPressed: function(mouse) {
                var v = valueFromMouse(mouse.x);
                // Snap to 0.01 steps
                v = Math.round(v * 100) / 100;
                root.adjusted(v);
            }

            onPositionChanged: function(mouse) {
                if (pressed) {
                    var v = valueFromMouse(mouse.x);
                    v = Math.round(v * 100) / 100;
                    root.adjusted(v);
                }
            }
        }
    }

    Text {
        text: root.displayPercent + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeTiny
        font.bold: true
        color: Theme.surfaceVariantFg
        Layout.preferredWidth: 36
        horizontalAlignment: Text.AlignRight
    }
}
