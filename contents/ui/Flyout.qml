/*
 * The popup window. A frameless, transparent PlasmaCore.Dialog: Plasma
 * places it next to the panel, and FlyoutContent draws the Windows-style
 * floating cards and animations instead of the Plasma dialog frame.
 */
import QtQuick
import org.kde.plasma.core as PlasmaCore

PlasmaCore.Dialog {
    id: dialog

    property QtObject backend
    property var tileOrder: []
    property var hiddenTiles: []
    signal tileOrderEdited(var order)
    signal hiddenTilesEdited(var hidden)

    readonly property bool closing: content.closing

    type: PlasmaCore.Dialog.PopupMenu
    backgroundHints: PlasmaCore.Dialog.NoBackground
    flags: Qt.WindowStaysOnTopHint
    hideOnWindowDeactivate: false

    function openFlyout() {
        if (!visible) {
            visible = true
            content.open()
            requestActivate()
        } else if (closing) {
            content.open()
        }
    }
    function closeFlyout() {
        if (visible) {
            content.close()
        }
    }
    function toggle() {
        if (visible && !closing) {
            closeFlyout()
        } else {
            openFlyout()
        }
    }

    // Clicking anywhere else deactivates the window: animate out.
    onActiveChanged: if (!active && visible) content.close()

    mainItem: FlyoutContent {
        id: content
        backend: dialog.backend
        expanded: dialog.visible
        tileOrder: dialog.tileOrder
        hiddenTiles: dialog.hiddenTiles
        onTileOrderEdited: (order) => dialog.tileOrderEdited(order)
        onHiddenTilesEdited: (hidden) => dialog.hiddenTilesEdited(hidden)
        onClosed: dialog.visible = false
    }
}
