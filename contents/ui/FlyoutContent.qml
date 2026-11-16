/*
 * Everything inside the flyout window: optional media card + quick
 * settings card, floating WinTheme.flyoutGap above the taskbar.
 *
 * Motion measured from Windows 11 24H2: the panel slides up its full height
 * from behind the taskbar edge (no fade), fast at first and settling over
 * ~330 ms; closing drops it straight back down in ~170 ms, accelerating.
 * The window clips at its bottom edge, which sits on the panel, so the card
 * appears to come out from behind the taskbar.
 *
 * The window keeps a fixed size; the cards sit at its bottom and the
 * transparent area above them closes the flyout when clicked.
 */
import QtQuick

Item {
    id: content

    required property QtObject backend
    property var tileOrder: []
    property var hiddenTiles: []
    property bool expanded: false          // window visible

    signal tileOrderEdited(var order)
    signal hiddenTilesEdited(var hidden)
    signal closed()                        // close animation finished

    readonly property bool closing: closeAnim.running
    readonly property int gap: WinTheme.flyoutGap

    implicitWidth: WinTheme.flyoutWidth + 2 * gap
    implicitHeight: gap + 176 + 12 + 448 + gap
    clip: true
    readonly property real hiddenOffset: cards.height + gap + 2

    focus: true
    Keys.onEscapePressed: if (!panel.goBack()) close()

    function open() {
        closeAnim.stop()
        openAnim.restart()
        forceActiveFocus()
    }
    function close() {
        if (!closeAnim.running) {
            openAnim.stop()
            closeAnim.restart()
        }
    }

    // Clicks on the transparent part of the window behave like clicking outside.
    MouseArea {
        anchors.fill: parent
        onClicked: (mouse) => {
            const p = mapToItem(cards, mouse.x, mouse.y)
            if (!cards.contains(p)) {
                content.close()
            }
        }
    }

    Loader {
        id: mpris
        source: "MprisSource.qml"
    }

    Column {
        id: cards
        x: content.gap
        anchors { bottom: parent.bottom; bottomMargin: content.gap }
        spacing: 12
        // Starts hidden; set imperatively so later height changes (sub-pages) don't re-hide it.
        transform: Translate { id: slide; y: 10000 }

        MediaCard {
            id: media
            width: WinTheme.flyoutWidth
            media: mpris.status === Loader.Ready ? mpris.item : null
            visible: active
        }
        QuickPanel {
            id: panel
            width: WinTheme.flyoutWidth
            backend: content.backend
            expanded: content.expanded
            tileOrder: content.tileOrder
            hiddenTiles: content.hiddenTiles
            onTileOrderEdited: (order) => content.tileOrderEdited(order)
            onHiddenTilesEdited: (hidden) => content.hiddenTilesEdited(hidden)
            onCloseRequested: content.close()
        }
    }

    ParallelAnimation {
        id: openAnim
        NumberAnimation { target: slide; property: "y"; from: content.hiddenOffset; to: 0; duration: 333; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate }
    }
    SequentialAnimation {
        id: closeAnim
        NumberAnimation { target: slide; property: "y"; to: content.hiddenOffset; duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.accelerate }
        ScriptAction { script: content.closed() }
    }
}
