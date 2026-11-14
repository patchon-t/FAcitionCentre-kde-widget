/*
 * Everything inside the flyout window: optional media card + quick
 * settings card, floating WinTheme.flyoutGap above the taskbar, with the
 * Windows 11 open (slide up + fade) and close (slide down + fade) motion.
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
        opacity: 0
        transform: Translate { id: slide; y: 0 }

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

    // Windows 11 flyout entrance: rises ~80 px with a decelerating curve while fading in.
    ParallelAnimation {
        id: openAnim
        NumberAnimation { target: slide; property: "y"; from: 80; to: 0; duration: 333; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate }
        NumberAnimation { target: cards; property: "opacity"; from: 0; to: 1; duration: WinTheme.normal; easing.type: Easing.Linear }
    }
    // Exit: drops back towards the taskbar and fades, quicker, accelerating.
    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
            NumberAnimation { target: slide; property: "y"; to: 60; duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.accelerate }
            NumberAnimation { target: cards; property: "opacity"; to: 0; duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.accelerate }
        }
        ScriptAction { script: content.closed() }
    }
}
