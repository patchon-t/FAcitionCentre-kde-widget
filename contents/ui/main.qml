/*
 * Quick Settings: a Windows 11 style quick settings popup for Plasma 6.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.icon: "configure"
    Plasmoid.status: PlasmaCore.Types.ActiveStatus

    toolTipMainText: "Quick Settings"
    toolTipSubText: {
        const parts = []
        if (sys.airplaneMode) {
            parts.push("Airplane mode")
        } else if (sys.wifiAvailable) {
            parts.push(sys.wifiSsid !== "" ? "Wi-Fi: " + sys.wifiSsid : sys.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off")
        }
        if (sys.volumeAvailable) {
            parts.push(sys.muted ? "Muted" : "Volume " + Math.round(sys.volume * 100) + "%")
        }
        if (sys.hasBattery) {
            parts.push("Battery " + sys.batteryPercent + "%")
        }
        return parts.join(" · ")
    }

    Backend {
        id: sys
        active: root.expanded
    }

    compactRepresentation: MouseArea {
        id: compact

        property bool wasExpanded: false

        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onPressed: wasExpanded = root.expanded
        onClicked: root.expanded = !wasExpanded

        Accessible.role: Accessible.Button
        Accessible.name: "Quick Settings"

        Kirigami.Icon {
            anchors.fill: parent
            source: Plasmoid.icon
            active: compact.containsMouse
        }
    }

    fullRepresentation: QuickPanel {
        backend: sys
        expanded: root.expanded
        tileOrder: Plasmoid.configuration.tileOrder
        hiddenTiles: Plasmoid.configuration.hiddenTiles
        onTileOrderEdited: (order) => Plasmoid.configuration.tileOrder = order
        onHiddenTilesEdited: (hidden) => Plasmoid.configuration.hiddenTiles = hidden
        onCloseRequested: root.expanded = false
    }
}
