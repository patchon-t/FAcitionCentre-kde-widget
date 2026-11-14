/*
 * The Windows 11 quick settings card: tile grid, sliders, footer, and the
 * sub-pages that slide in over it.
 */
import QtQuick
import QtQuick.Controls as QQC2

WinCard {
    id: panel

    required property QtObject backend
    property bool expanded: false
    property var tileOrder: []
    property var hiddenTiles: []

    signal tileOrderEdited(var order)
    signal hiddenTilesEdited(var hidden)
    signal closeRequested()

    property bool editMode: false
    readonly property bool onSubPage: stack.depth > 1

    function goBack() {
        if (addMenu.open) {
            addMenu.open = false
        } else if (stack.depth > 1) {
            stack.pop()
        } else if (editMode) {
            editMode = false
        } else {
            return false
        }
        return true
    }

    implicitWidth: WinTheme.flyoutWidth
    implicitHeight: stack.currentItem && stack.depth > 1 ? stack.currentItem.preferredHeight : mainPage.preferredHeight
    height: implicitHeight
    Behavior on height {
        enabled: panel.expanded
        NumberAnimation { duration: WinTheme.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate }
    }

    onExpandedChanged: {
        if (!expanded) {
            editMode = false
            addMenu.open = false
            stack.pop(null, QQC2.StackView.Immediate)
        }
    }

    // ---- tiles ----------------------------------------------------------------
    readonly property var defs: ({
        wifi: wifiDef,
        bluetooth: bluetoothDef,
        airplane: airplaneDef,
        nightlight: nightLightDef,
        dnd: dndDef,
        project: projectDef
    })
    readonly property var allTiles: ["wifi", "bluetooth", "airplane", "nightlight", "dnd", "project"]

    // Config order, minus unknown ids, plus any tile missing from it.
    function fullOrder() {
        const out = []
        for (const id of tileOrder) {
            if (allTiles.indexOf(id) >= 0 && out.indexOf(id) < 0) {
                out.push(id)
            }
        }
        for (const id of allTiles) {
            if (out.indexOf(id) < 0) {
                out.push(id)
            }
        }
        return out
    }
    readonly property var hiddenList: fullOrder().filter(id => hiddenTiles.indexOf(id) >= 0)

    ListModel { id: tileModel }

    function modelIds() {
        const ids = []
        for (let i = 0; i < tileModel.count; ++i) {
            ids.push(tileModel.get(i).tileId)
        }
        return ids
    }
    function rebuild() {
        const shown = fullOrder().filter(id => hiddenTiles.indexOf(id) < 0)
        if (JSON.stringify(shown) === JSON.stringify(modelIds())) {
            return
        }
        tileModel.clear()
        for (const id of shown) {
            tileModel.append({ tileId: id })
        }
    }
    function commit(hidden) {
        const shown = modelIds()
        tileOrderEdited(shown.concat(hidden))
        hiddenTilesEdited(hidden)
    }
    function unpin(id) {
        const ids = modelIds()
        const i = ids.indexOf(id)
        if (i >= 0) {
            tileModel.remove(i)
        }
        commit(hiddenList.concat([id]))
    }
    function pin(id) {
        tileModel.append({ tileId: id })
        commit(hiddenList.filter(h => h !== id))
    }
    Component.onCompleted: rebuild()
    onTileOrderChanged: if (!dragging) rebuild()
    onHiddenTilesChanged: if (!dragging) rebuild()
    property bool dragging: false

    TileDef {
        id: wifiDef
        glyph: "wifi-4"
        label: backend.wifiSsid !== "" ? backend.wifiSsid : "Wi-Fi"
        tooltip: !backend.wifiEnabled ? "Wi-Fi is off"
               : backend.wifiSsid !== "" ? "Connected to " + backend.wifiSsid
               : "Wi-Fi is on, not connected"
        moreTooltip: "Manage Wi-Fi connections"
        checked: backend.wifiEnabled
        hasMore: true
        available: backend.wifiAvailable
        unavailableReason: !backend.probed ? "" : backend.has("nmcli") ? "No Wi-Fi adapter found" : "Wi-Fi needs nmcli (network-manager), which is not installed"
        enabled: !backend.airplaneMode
        disabledReason: "Wi-Fi is unavailable while airplane mode is on"
        onToggled: backend.setWifi(!backend.wifiEnabled)
        onMoreClicked: stack.push(wifiPage)
    }
    TileDef {
        id: bluetoothDef
        readonly property string deviceName: backend.btConnected.length > 0 ? backend.btConnected[0].name : ""
        glyph: "bluetooth"
        label: deviceName !== "" ? deviceName : "Bluetooth"
        tooltip: !backend.btEnabled ? "Bluetooth is off"
               : deviceName !== "" ? "Connected to " + backend.btConnected.map(d => d.name).join(", ")
               : "Bluetooth is on, not connected"
        moreTooltip: "Manage Bluetooth devices"
        checked: backend.btEnabled
        hasMore: true
        available: backend.btAvailable
        unavailableReason: !backend.probed ? "" : backend.has("bluetoothctl") ? "No Bluetooth adapter found" : "Bluetooth needs bluetoothctl (bluez), which is not installed"
        enabled: !backend.airplaneMode
        disabledReason: "Bluetooth is unavailable while airplane mode is on"
        onToggled: backend.setBluetooth(!backend.btEnabled)
        onMoreClicked: stack.push(bluetoothPage)
    }
    TileDef {
        id: airplaneDef
        glyph: "airplane"
        label: "Airplane mode"
        tooltip: backend.airplaneMode ? "Airplane mode is on" : "Airplane mode is off"
        checked: backend.airplaneMode
        available: backend.airplaneAvailable
        unavailableReason: backend.probed ? "Airplane mode needs rfkill or nmcli; neither is installed" : ""
        onToggled: backend.setAirplane(!backend.airplaneMode)
    }
    TileDef {
        id: nightLightDef
        glyph: "night-light"
        label: "Night light"
        tooltip: backend.nightLight ? "Night light is on" : "Night light is off"
        checked: backend.nightLight
        available: backend.nightLightAvailable
        unavailableReason: !backend.probed ? "" : backend.qdbus === "" ? "Night light needs qdbus6, which is not installed"
                                                                        : "Night light needs kwriteconfig6, which is not installed"
        onToggled: backend.setNightLight(!backend.nightLight)
    }
    TileDef {
        id: dndDef
        glyph: "moon"
        label: "Focus assist"
        tooltip: backend.dnd ? "Focus assist is on: notifications are silenced" : "Focus assist is off"
        checked: backend.dnd
        available: backend.dndAvailable
        unavailableReason: "The Plasma notification module (org.kde.notificationmanager) could not be loaded"
        onToggled: backend.setDnd(!backend.dnd)
    }
    TileDef {
        id: projectDef
        glyph: "project"
        label: "Project"
        tooltip: "Choose a display mode"
        available: backend.projectAvailable
        unavailableReason: backend.probed ? "Project needs qdbus6, which is not installed" : ""
        onToggled: {
            panel.closeRequested()
            backend.project()
        }
    }

    // ---- footer strip (drawn by the card so sliding pages stay inside rounded corners)
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 1 }
        height: WinTheme.footerHeight
        radius: WinTheme.cardRadius - 1
        color: WinTheme.footer
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: parent.radius
            color: parent.color
        }
    }

    // ---- pages -------------------------------------------------------------------
    QQC2.StackView {
        id: stack
        anchors.fill: parent
        anchors.margins: 1
        clip: true
        initialItem: mainPage
        background: null

        readonly property real shift: width * 0.3
        pushEnter: Transition {
            NumberAnimation { property: "x"; from: stack.shift; to: 0; duration: WinTheme.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: WinTheme.normal }
        }
        pushExit: Transition {
            NumberAnimation { property: "x"; from: 0; to: -stack.shift; duration: WinTheme.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate }
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: WinTheme.fast }
        }
        popEnter: Transition {
            NumberAnimation { property: "x"; from: -stack.shift; to: 0; duration: WinTheme.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: WinTheme.normal }
        }
        popExit: Transition {
            NumberAnimation { property: "x"; from: 0; to: stack.shift; duration: WinTheme.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate }
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: WinTheme.fast }
        }
    }

    Component {
        id: wifiPage
        WifiPage {
            backend: panel.backend
            onBack: stack.pop()
            onOpenSettings: { panel.closeRequested(); panel.backend.openKcm("kcm_networkmanagement") }
        }
    }
    Component {
        id: bluetoothPage
        BluetoothPage {
            backend: panel.backend
            onBack: stack.pop()
            onOpenSettings: { panel.closeRequested(); panel.backend.openKcm("kcm_bluetooth") }
        }
    }
    Component {
        id: audioPage
        AudioPage {
            backend: panel.backend
            onBack: stack.pop()
            onOpenSettings: { panel.closeRequested(); panel.backend.openKcm("kcm_pulseaudio") }
        }
    }

    Item {
        id: mainPage

        readonly property int preferredHeight: 2 + WinTheme.padding + grid.height + 10 + sliders.height + 18 + WinTheme.footerHeight

        GridView {
            id: grid
            x: WinTheme.padding
            y: WinTheme.padding
            width: 3 * cellWidth
            height: Math.ceil(count / 3) * cellHeight
            cellWidth: WinTheme.tileWidth + WinTheme.tileGap
            cellHeight: WinTheme.tileRowHeight
            interactive: false
            model: tileModel

            Behavior on height { NumberAnimation { duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
            displaced: Transition { NumberAnimation { properties: "x,y"; duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
            move: Transition { NumberAnimation { properties: "x,y"; duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
            add: Transition { NumberAnimation { property: "scale"; from: 0.8; to: 1; duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } NumberAnimation { property: "opacity"; from: 0; to: 1; duration: WinTheme.normal } }
            remove: Transition { NumberAnimation { property: "scale"; to: 0.8; duration: WinTheme.fast } NumberAnimation { property: "opacity"; to: 0; duration: WinTheme.fast } }

            delegate: DropArea {
                id: cell
                required property string tileId
                required property int index
                readonly property TileDef def: panel.defs[tileId]
                readonly property bool usable: def.available && def.enabled

                width: grid.cellWidth
                height: grid.cellHeight
                keys: ["qs-tile"]
                onEntered: (drag) => {
                    const from = drag.source.cellIndex
                    if (from !== undefined && from !== index) {
                        tileModel.move(from, index, 1)
                    }
                }

                Item {
                    id: dragItem
                    property int cellIndex: cell.index
                    width: WinTheme.tileWidth
                    height: WinTheme.tileRowHeight
                    anchors { left: cell.left; top: cell.top }

                    Drag.active: dragArea.drag.active
                    Drag.source: dragItem
                    Drag.keys: ["qs-tile"]
                    Drag.hotSpot.x: width / 2
                    Drag.hotSpot.y: WinTheme.tileHeight / 2

                    states: State {
                        when: dragArea.drag.active
                        ParentChange { target: dragItem; parent: grid }
                        AnchorChanges { target: dragItem; anchors.left: undefined; anchors.top: undefined }
                        PropertyChanges { target: dragItem; z: 10; scale: 1.06; opacity: 0.92 }
                    }

                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        enabled: panel.editMode
                        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                        drag.target: dragItem
                        onPressed: panel.dragging = true
                        onReleased: {
                            dragItem.Drag.drop()
                            panel.dragging = false
                            panel.commit(panel.hiddenList)
                        }
                        onCanceled: panel.dragging = false
                    }

                    ToggleTile {
                        anchors.fill: parent
                        glyph: cell.def.glyph
                        label: cell.def.label
                        tooltip: cell.def.tooltip
                        moreTooltip: cell.def.moreTooltip
                        checked: cell.def.checked
                        hasMore: cell.def.hasMore
                        editMode: panel.editMode
                        enabled: cell.usable || panel.editMode
                        onToggled: cell.def.toggled()
                        onMoreClicked: cell.def.moreClicked()
                        onUnpinClicked: panel.unpin(cell.tileId)
                    }

                    // A disabled tile gets no hover; explain why it is disabled.
                    HoverHandler {
                        id: cellHover
                        enabled: !cell.usable && !panel.editMode
                    }
                    WinToolTip {
                        text: !cell.def.available ? cell.def.unavailableReason : cell.def.disabledReason
                        shown: cellHover.hovered
                    }
                }
            }
        }

        Column {
            id: sliders
            x: 10
            y: grid.y + grid.height + 10
            width: parent.width - 20
            spacing: 20

            SliderRow {
                width: parent.width
                visible: panel.backend.brightnessAvailable
                glyph: "sun"
                iconTooltip: "Brightness"
                sliderName: "Brightness"
                value: panel.backend.brightness
                onMoved: (value) => panel.backend.setBrightness(value)
            }
            SliderRow {
                width: parent.width
                visible: panel.backend.volumeAvailable
                glyph: panel.backend.volumeGlyph
                iconClickable: true
                iconTooltip: panel.backend.muted ? "Unmute" : "Mute"
                sliderName: "Volume"
                value: panel.backend.volume
                hasMore: true
                moreTooltip: "Select a sound output"
                onMoved: (value) => panel.backend.setVolume(value)
                onIconClicked: panel.backend.toggleMute()
                onMoreClicked: stack.push(audioPage)
            }
        }

        Footer {
            id: footer
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            hasBattery: panel.backend.hasBattery
            batteryGlyph: panel.backend.batteryGlyph
            batteryPercent: panel.backend.batteryPercent
            batteryText: panel.backend.batteryStatusText
            editMode: panel.editMode
            canAdd: panel.hiddenList.length > 0
            onEditClicked: panel.editMode = true
            onDoneClicked: { addMenu.open = false; panel.editMode = false }
            onAddClicked: (anchor) => addMenu.open = !addMenu.open
            onSettingsClicked: {
                panel.closeRequested()
                panel.backend.openSystemSettings()
            }
        }

        // ---- "Add" menu (edit mode) ----------------------------------------------
        MouseArea {   // click outside closes it
            anchors.fill: parent
            visible: addMenu.open
            onClicked: addMenu.open = false
        }
        WinCard {
            id: addMenu
            property bool open: false
            visible: opacity > 0
            opacity: open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: WinTheme.fast } }
            anchors { right: parent.right; rightMargin: 12; bottom: footer.top; bottomMargin: -4 }
            transform: Translate {
                y: addMenu.open ? 0 : 8
                Behavior on y { NumberAnimation { duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
            }
            width: 200
            height: menuColumn.implicitHeight + 8
            onVisibleChanged: if (panel.hiddenList.length === 0) open = false

            Column {
                id: menuColumn
                x: 4
                y: 4
                width: parent.width - 8
                Repeater {
                    model: panel.hiddenList
                    delegate: Rectangle {
                        required property string modelData
                        width: menuColumn.width
                        height: 36
                        radius: WinTheme.controlRadius
                        color: menuArea.pressed ? WinTheme.subtlePressed : menuArea.containsMouse ? WinTheme.subtleHover : "transparent"
                        Row {
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            spacing: 12
                            FluentIcon { anchors.verticalCenter: parent.verticalCenter; glyph: panel.defs[modelData].glyph }
                            WinText { anchors.verticalCenter: parent.verticalCenter; text: panel.defs[modelData].label }
                        }
                        MouseArea {
                            id: menuArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                panel.pin(modelData)
                                if (panel.hiddenList.length <= 1) addMenu.open = false
                            }
                        }
                    }
                }
            }
        }
    }
}
