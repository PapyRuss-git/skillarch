import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../.."
import "../common"

ModuleLabel {
    id: root

    property var device: UPower.displayDevice
    property real rawPercent: device ? device.percentage : -1
    // UPower may return 0-1 (fraction) or 0-100 — handle both
    property int percent: {
        if (rawPercent < 0) return 0;
        if (rawPercent > 0 && rawPercent <= 1.0) return Math.round(rawPercent * 100);
        return Math.round(rawPercent);
    }
    property bool charging: device ? device.state === UPowerDeviceState.Charging : false
    property bool hasBattery: device ? device.isPresent : false

    visible: hasBattery
    text: batteryIcon + " " + percent + "%"
    textColor: charging ? Theme.primary
             : percent <= 20 ? Theme.error
             : Theme.primary

    property string batteryIcon: {
        if (charging) return "\u{f0084}";
        if (percent > 90) return "\u{f0079}";
        if (percent > 70) return "\u{f0080}";
        if (percent > 50) return "\u{f007e}";
        if (percent > 30) return "\u{f007c}";
        if (percent > 10) return "\u{f007a}";
        return "\u{f0083}";
    }
}
