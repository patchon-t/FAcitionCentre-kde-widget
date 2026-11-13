/*
 * Volume backend using plasma-pa's QML plugin (org.kde.plasma.private.volume).
 * Signal driven. Loaded through a Loader; if it fails the backend falls
 * back to wpctl.
 */
import QtQuick
import QtQml.Models
import org.kde.plasma.private.volume

Item {
    id: plugin

    // PA_VOLUME_NORM: 100% in PulseAudio volume units.
    readonly property int normalVolume: 65536

    property var sink: null          // default output (PulseAudioQt sink object)
    property var sinks: []           // [{ name, isDefault, ref }]

    readonly property bool available: sink !== null
    readonly property real volume: sink ? sink.volume / normalVolume : 0
    readonly property bool muted: sink ? sink.muted : false

    function setVolume(fraction) {
        if (sink) {
            sink.volume = Math.round(Math.max(0, Math.min(1, fraction)) * normalVolume)
        }
    }
    function setMuted(m) {
        if (sink) {
            sink.muted = m
        }
    }
    function setDefault(entry) {
        if (entry && entry.ref) {
            entry.ref["default"] = true
        }
    }

    function rebuild() {
        const list = []
        let def = null
        for (let i = 0; i < collector.count; ++i) {
            const o = collector.objectAt(i)
            if (!o || !o.pulseObject) {
                continue
            }
            list.push({ name: o.pulseObject.description || o.pulseObject.name, isDefault: o.isDefault, ref: o.pulseObject })
            if (o.isDefault) {
                def = o.pulseObject
            }
        }
        if (!def && list.length > 0) {
            def = list[0].ref
        }
        sinks = list
        sink = def
    }

    Instantiator {
        id: collector
        model: SinkModel {}
        delegate: QtObject {
            required property var model
            readonly property var pulseObject: model.PulseObject
            readonly property bool isDefault: pulseObject ? Boolean(pulseObject["default"]) : false
            readonly property string description: pulseObject ? String(pulseObject.description) : ""
            onIsDefaultChanged: Qt.callLater(plugin.rebuild)
            onDescriptionChanged: Qt.callLater(plugin.rebuild)
        }
        onObjectAdded: Qt.callLater(plugin.rebuild)
        onObjectRemoved: Qt.callLater(plugin.rebuild)
    }
}
