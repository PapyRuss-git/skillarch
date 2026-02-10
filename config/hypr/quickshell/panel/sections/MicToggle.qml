import QtQuick
import Quickshell.Services.Pipewire
import "../.."
import "../common"

ToggleRow {
    id: root

    property var source: Pipewire.defaultAudioSource
    property bool muted: source && source.audio ? source.audio.muted : false

    icon: muted ? "\u{f036d}" : "\u{f036c}"
    label: "Mic"
    active: !muted

    onClicked: {
        if (source && source.audio)
            source.audio.muted = !source.audio.muted;
    }
}
