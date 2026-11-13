/*
 * Optional change notifier for NetworkManager state (plasma-nm QML plugin).
 * Loaded through a Loader: if the module is missing the plasmoid simply
 * falls back to polling nmcli while the popup is open.
 */
import QtQuick
import org.kde.plasma.networkmanagement as PlasmaNM

Item {
    id: notifier
    signal changed()

    PlasmaNM.EnabledConnections {
        onWirelessEnabledChanged: notifier.changed()
    }
    PlasmaNM.NetworkStatus {
        onActiveConnectionsChanged: notifier.changed()
    }
}
