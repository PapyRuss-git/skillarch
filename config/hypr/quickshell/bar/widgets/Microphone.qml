import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../.."
import "../common"

ClickableModule {
    id: root

    property var source: Pipewire.defaultAudioSource
    property bool muted: source && source.audio ? source.audio.muted : false

    text: muted ? "\u{f036d}" : "\u{f036c}"
    textColor: muted ? Theme.red : Theme.fgPrimary

    onClicked: {
        if (source && source.audio)
            source.audio.muted = !source.audio.muted;
    }
}
