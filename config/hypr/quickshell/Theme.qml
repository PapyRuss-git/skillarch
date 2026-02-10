pragma Singleton
import QtQuick

QtObject {
    // Everforest Hard Dark — Background
    readonly property color bgDim:     "#1E2326"
    readonly property color bgBase:    "#272E33"
    readonly property color bgSurface: "#2E383C"
    readonly property color bgFloat:   "#374145"
    readonly property color bgSidebar: "#414B50"
    readonly property color bgSelect:  "#4F5B58"

    // Everforest Hard Dark — Foreground
    readonly property color fgPrimary: "#D3C6AA"
    readonly property color fgSecond:  "#9DA9A0"
    readonly property color fgDimmed:  "#7A8478"

    // Everforest Hard Dark — Accent
    readonly property color red:    "#E67E80"
    readonly property color orange: "#E69875"
    readonly property color yellow: "#DBBC7F"
    readonly property color green:  "#A7C080"
    readonly property color blue:   "#7FBBB3"
    readonly property color aqua:   "#83C092"
    readonly property color purple: "#D699B6"

    // Everforest Hard Dark — Background variants
    readonly property color bgRed:   "#4C3743"
    readonly property color bgGreen: "#3C4841"

    // Bar dimensions
    readonly property int barHeight: 32
    readonly property int barRadius: 9
    readonly property int moduleRadius: 7
    readonly property int popupRadius: 12

    // Fonts
    readonly property string fontFamily: "JetBrains Mono Nerd Font"
    readonly property int fontSizeNormal: 14
    readonly property int fontSizeSmall: 12
    readonly property int fontSizeTiny: 11
    readonly property int fontSizeLarge: 18

    // Borders
    readonly property color borderSubtle: Qt.rgba(0.827, 0.776, 0.667, 0.15)
    readonly property color borderLight:  Qt.rgba(0.827, 0.776, 0.667, 0.25)
    readonly property color borderHover:  Qt.rgba(0.827, 0.776, 0.667, 0.35)
    readonly property color barBg: Qt.rgba(0.118, 0.137, 0.149, 0.65)

    // Quick-Settings panel
    readonly property int panelWidth: 340

    // Overview dimensions
    readonly property real overviewScale: 0.16
    readonly property int overviewRows: 2
    readonly property int overviewColumns: 5
    readonly property bool overviewHideEmptyRows: true
    readonly property int overviewRounding: 12
    readonly property int windowRounding: 8
}
