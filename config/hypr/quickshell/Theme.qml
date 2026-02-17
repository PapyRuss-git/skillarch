pragma Singleton
import QtQuick

QtObject {
    // ── Section 1: Everforest Hard Dark — Raw Palette ──────────────

    // Backgrounds
    readonly property color bgDim:     "#1E2326"
    readonly property color bg0:       "#272E33"
    readonly property color bg1:       "#2E383C"
    readonly property color bg2:       "#374145"
    readonly property color bg3:       "#414B50"
    readonly property color bg4:       "#495156"
    readonly property color bg5:       "#4F5B58"

    // Foregrounds
    readonly property color fg:        "#D3C6AA"
    readonly property color grey0:     "#7A8478"
    readonly property color grey1:     "#859289"
    readonly property color grey2:     "#9DA9A0"

    // Accents
    readonly property color red:       "#E67E80"
    readonly property color orange:    "#E69875"
    readonly property color yellow:    "#DBBC7F"
    readonly property color green:     "#A7C080"
    readonly property color aqua:      "#83C092"
    readonly property color blue:      "#7FBBB3"
    readonly property color purple:    "#D699B6"

    // Background variants
    readonly property color bgRed:     "#493B40"
    readonly property color bgVisual:  "#4C3743"
    readonly property color bgYellow:  "#45443C"
    readonly property color bgGreen:   "#3C4841"
    readonly property color bgBlue:    "#384B55"
    readonly property color bgPurple:  "#463F48"

    // ── Section 2: Material Design 3 — Semantic Tokens ─────────────

    // Primary (green)
    readonly property color primary:              green
    readonly property color primaryFg:            bgDim
    readonly property color primaryContainer:     bgGreen
    readonly property color primaryContainerFg:   green

    // Secondary (blue)
    readonly property color secondary:            blue
    readonly property color secondaryFg:          bgDim
    readonly property color secondaryContainer:   bgBlue
    readonly property color secondaryContainerFg: blue

    // Tertiary (purple)
    readonly property color tertiary:             purple
    readonly property color tertiaryFg:           bgDim
    readonly property color tertiaryContainer:    bgPurple
    readonly property color tertiaryContainerFg:  purple

    // Error (red)
    readonly property color error:                red
    readonly property color errorFg:              bgDim
    readonly property color errorContainer:       bgRed
    readonly property color errorContainerFg:     red

    // Surface
    readonly property color surface:                  bg0
    readonly property color surfaceDim:               bgDim
    readonly property color surfaceContainerLowest:   bgDim
    readonly property color surfaceContainerLow:      bg1
    readonly property color surfaceContainer:         bg2
    readonly property color surfaceContainerHigh:     bg3
    readonly property color surfaceContainerHighest:  bg5

    // Surface foregrounds
    readonly property color surfaceFg:            fg
    readonly property color surfaceVariantFg:     grey2

    // Outline
    readonly property color outline:              grey1
    readonly property color outlineVariant:        grey0

    // Warning & Info (custom M3 extensions)
    readonly property color warning:              orange
    readonly property color warningContainer:     bgYellow
    readonly property color warningFg:            bgDim
    readonly property color info:                 yellow

    // Shadow & Scrim
    readonly property color shadow:               "#000000"
    readonly property color scrim:                "#000000"

    // ── Section 3: Helpers ─────────────────────────────────────────

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    readonly property color borderSubtle: Qt.rgba(surfaceFg.r, surfaceFg.g, surfaceFg.b, 0.15)
    readonly property color borderLight:  Qt.rgba(surfaceFg.r, surfaceFg.g, surfaceFg.b, 0.25)
    readonly property color borderHover:  Qt.rgba(surfaceFg.r, surfaceFg.g, surfaceFg.b, 0.35)
    readonly property color barBg:        Qt.rgba(surfaceDim.r, surfaceDim.g, surfaceDim.b, 0.65)

    // ── Section 4: Dimensions ──────────────────────────────────────

    // Bar
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

    // Quick-Settings panel
    readonly property int panelWidth: 340

    // Overview
    readonly property real overviewScale: 0.16
    readonly property int overviewRows: 2
    readonly property int overviewColumns: 5
    readonly property bool overviewHideEmptyRows: true
    readonly property int overviewRounding: 12
    readonly property int windowRounding: 8
}
