import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../.."
import "../common"

SliderRow {
    id: root

    property var sink: Pipewire.defaultAudioSink

    icon: "\u{f057e}"
    value: sink && sink.audio ? sink.audio.volume : 0

    onAdjusted: function(newValue) {
        if (sink && sink.audio)
            sink.audio.volume = newValue;
    }
}
