/*
 * Network status icon from plasma-nm (org.kde.plasma.networkmanagement):
 * the same icon the stock Networks applet shows (Wi-Fi strength, wired,
 * VPN, airplane mode, limited connectivity), updated by signals.
 * Loaded through a Loader; if it fails, Backend computes its own icon.
 */
import QtQuick
import org.kde.plasma.networkmanagement as PlasmaNM

Item {
    readonly property string iconName: provider.connectionIcon
    readonly property bool connecting: provider.connecting

    PlasmaNM.NetworkStatus {
        id: networkStatus
    }
    PlasmaNM.ConnectionIcon {
        id: provider
        connectivity: networkStatus.connectivity
    }
}
