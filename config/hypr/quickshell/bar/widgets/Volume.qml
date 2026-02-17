import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../.."
import "../common"

ClickableModule {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property int percent: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    property bool muted: sink && sink.audio ? sink.audio.muted : false

    text: volumeIcon + " " + percent + "%"
    textColor: muted ? Theme.outlineVariant : Theme.surfaceFg

    property string volumeIcon: {
        if (muted) return "\u{f0e08}";
        if (percent > 65) return "\u{f057e}";
        if (percent > 30) return "\u{f0580}";
        return "\u{f057f}";
    }

    onClicked: pavuLaunch.startDetached()

    onScrolledUp: {
        if (sink && sink.audio)
            sink.audio.volume = Math.min(1.0, sink.audio.volume + 0.05);
    }

    onScrolledDown: {
        if (sink && sink.audio)
            sink.audio.volume = Math.max(0.0, sink.audio.volume - 0.05);
    }

    Process {
        id: pavuLaunch
        command: ["pavucontrol"]
    }
}
