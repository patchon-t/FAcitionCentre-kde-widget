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
        if (sys.networkIconAvailable) {
            parts.push(sys.networkStatusText)
        }
        if (sys.volumeAvailable) {
            parts.push(sys.muted ? "Muted" : "Volume " + Math.round(sys.volume * 100) + "%")
        }
        if (sys.hasBattery) {
            parts.push("Battery " + sys.batteryStatusText)
        }
        return parts.join(" · ")
    }

    Backend {
        id: sys
        active: root.expanded
    }

    compactRepresentation: CompactIcons {
        backend: sys
        vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        expanded: root.expanded
        onExpandRequested: (expand) => root.expanded = expand
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
