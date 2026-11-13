/*
 * Optional change notifier for BlueZ state (org.kde.bluezqt QML plugin).
 * Loaded through a Loader: if the module is missing the plasmoid falls
 * back to polling bluetoothctl while the popup is open.
 */
import QtQuick
import org.kde.bluezqt as BluezQt

Item {
    id: notifier
    signal changed()

    Connections {
        target: BluezQt.Manager
        ignoreUnknownSignals: true
        function onBluetoothOperationalChanged() { notifier.changed() }
        function onBluetoothBlockedChanged() { notifier.changed() }
        function onAdapterChanged() { notifier.changed() }
        function onDeviceChanged() { notifier.changed() }
        function onDeviceAdded() { notifier.changed() }
        function onDeviceRemoved() { notifier.changed() }
    }
}
