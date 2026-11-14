/*
 * Quick Settings: a Windows 11 style quick settings flyout for Plasma 6.
 */
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.icon: "configure"
    Plasmoid.status: flyout.visible ? PlasmaCore.Types.AcceptingInputStatus : PlasmaCore.Types.ActiveStatus

    // We draw our own flyout (Flyout.qml) instead of Plasma's popup.
    preferredRepresentation: compactRepresentation
    fullRepresentation: Item {}

    toolTipMainText: sys.networkIconAvailable ? sys.networkStatusText : "Quick Settings"
    toolTipSubText: {
        const parts = []
        if (sys.volumeAvailable) {
            parts.push(sys.muted ? "Speakers: muted" : "Speakers: " + Math.round(sys.volume * 100) + "%")
        }
        if (sys.hasBattery) {
            parts.push("Battery: " + sys.batteryStatusText)
        }
        return parts.join("\n")
    }

    // Feed the Plasma colour scheme and widget settings into the Windows theme.
    Binding { target: WinTheme; property: "systemBackground"; value: Kirigami.Theme.backgroundColor }
    Binding { target: WinTheme; property: "systemAccent"; value: Kirigami.Theme.highlightColor }
    Binding { target: WinTheme; property: "mode"; value: Plasmoid.configuration.themeMode }
    Binding { target: WinTheme; property: "useSystemAccent"; value: Plasmoid.configuration.useSystemAccent }

    Backend {
        id: sys
        active: flyout.visible
    }

    compactRepresentation: CompactIcons {
        backend: sys
        vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        expanded: flyout.visible && !flyout.closing
        onExpandRequested: (expand) => expand ? flyout.openFlyout() : flyout.closeFlyout()
    }

    Flyout {
        id: flyout
        visualParent: root.compactRepresentationItem
        location: Plasmoid.location
        backend: sys
        tileOrder: Plasmoid.configuration.tileOrder
        hiddenTiles: Plasmoid.configuration.hiddenTiles
        onTileOrderEdited: (order) => Plasmoid.configuration.tileOrder = order
        onHiddenTilesEdited: (hidden) => Plasmoid.configuration.hiddenTiles = hidden
    }

    // Global shortcut (Configure > Keyboard Shortcuts) toggles the flyout.
    Connections {
        target: Plasmoid
        ignoreUnknownSignals: true
        function onActivated() { flyout.toggle() }
    }
}
