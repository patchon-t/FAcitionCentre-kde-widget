/*
 * The popup content: tile grid, sliders, footer, and the sliding sub-pages.
 */
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: panel

    required property QtObject backend
    // Popup is open.
    property bool expanded: false
    // From plasmoid config.
    property var tileOrder: []
    property var hiddenTiles: []

    signal tileOrderEdited(var order)
    signal hiddenTilesEdited(var hidden)
    signal closeRequested()

    property bool editMode: false

    readonly property var defs: ({
        wifi: wifiDef,
        bluetooth: bluetoothDef,
        airplane: airplaneDef,
        nightlight: nightLightDef,
        dnd: dndDef,
        project: projectDef
    })
    readonly property var defaultOrder: ["wifi", "bluetooth", "airplane", "nightlight", "dnd", "project"]

    // Config order, minus unknown ids, plus any tile missing from it.
    readonly property var order: {
        const out = []
        for (const id of tileOrder) {
            if (defaultOrder.indexOf(id) >= 0 && out.indexOf(id) < 0) {
                out.push(id)
            }
        }
        for (const id of defaultOrder) {
            if (out.indexOf(id) < 0) {
                out.push(id)
            }
        }
        return out
    }
    readonly property var shownTiles: editMode ? order : order.filter(id => hiddenTiles.indexOf(id) < 0)

    function toggleHidden(id) {
        const hidden = Array.from(hiddenTiles)
        const i = hidden.indexOf(id)
        if (i >= 0) {
            hidden.splice(i, 1)
        } else {
            hidden.push(id)
        }
        hiddenTilesEdited(hidden)
    }
    function moveTile(id, delta) {
        const o = Array.from(order)
        const i = o.indexOf(id)
        const j = i + delta
        if (i < 0 || j < 0 || j >= o.length) {
            return
        }
        o.splice(i, 1)
        o.splice(j, 0, id)
        tileOrderEdited(o)
    }

    onExpandedChanged: {
        if (!expanded) {
            editMode = false
            stack.pop(null, QQC2.StackView.Immediate)
        }
    }

    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.preferredWidth: Kirigami.Units.gridUnit * 20
    Layout.maximumWidth: Kirigami.Units.gridUnit * 24
    Layout.minimumHeight: mainColumn.implicitHeight
    Layout.preferredHeight: Math.max(mainColumn.implicitHeight, Kirigami.Units.gridUnit * 21)
    Layout.maximumHeight: Math.max(mainColumn.implicitHeight, Kirigami.Units.gridUnit * 26)

    // ---- tile definitions ----------------------------------------------------
    TileDef {
        id: wifiDef
        iconName: !backend.wifiEnabled ? "network-wireless-off"
                : backend.wifiSsid !== "" ? backend.wifiIconForSignal(backend.wifiSignal) : "network-wireless-disconnected"
        label: backend.wifiSsid !== "" ? backend.wifiSsid : "Wi-Fi"
        tooltip: !backend.wifiEnabled ? "Wi-Fi is off. Click to turn it on"
               : backend.wifiSsid !== "" ? "Connected to " + backend.wifiSsid + ". Click to turn Wi-Fi off"
               : "Wi-Fi is on, not connected. Click to turn it off"
        moreTooltip: "Show available Wi-Fi networks"
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
        iconName: !backend.btEnabled ? "network-bluetooth-inactive"
                : deviceName !== "" ? "network-bluetooth-activated" : "network-bluetooth"
        label: deviceName !== "" ? deviceName : "Bluetooth"
        tooltip: !backend.btEnabled ? "Bluetooth is off. Click to turn it on"
               : deviceName !== "" ? "Connected to " + backend.btConnected.map(d => d.name).join(", ") + ". Click to turn Bluetooth off"
               : "Bluetooth is on, no device connected. Click to turn it off"
        moreTooltip: "Show paired Bluetooth devices"
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
        iconName: backend.airplaneMode ? "network-flightmode-on" : "network-flightmode-off"
        label: "Airplane mode"
        tooltip: backend.airplaneMode ? "Airplane mode is on: all radios are off. Click to turn radios back on"
                                      : "Turn off Wi-Fi, Bluetooth and other radios"
        checked: backend.airplaneMode
        available: backend.airplaneAvailable
        unavailableReason: backend.probed ? "Airplane mode needs rfkill or nmcli; neither is installed" : ""
        onToggled: backend.setAirplane(!backend.airplaneMode)
    }
    TileDef {
        id: nightLightDef
        iconName: backend.nightLight ? "redshift-status-on" : "redshift-status-off"
        label: "Night light"
        tooltip: backend.nightLight ? "Night light is enabled. Click to turn it off"
                                    : "Use warmer colours to reduce eye strain"
        checked: backend.nightLight
        available: backend.nightLightAvailable
        unavailableReason: !backend.probed ? "" : backend.qdbus === "" ? "Night light needs qdbus6, which is not installed"
                                                                        : "Night light needs kwriteconfig6, which is not installed"
        onToggled: backend.setNightLight(!backend.nightLight)
    }
    TileDef {
        id: dndDef
        iconName: backend.dnd ? "notifications-disabled" : "notifications"
        label: "Do not disturb"
        tooltip: backend.dnd ? "Do not disturb is on: notifications are silenced. Click to turn it off"
                             : "Silence notifications"
        checked: backend.dnd
        available: backend.dndAvailable
        unavailableReason: "The Plasma notification module (org.kde.notificationmanager) could not be loaded"
        onToggled: backend.setDnd(!backend.dnd)
    }
    TileDef {
        id: projectDef
        iconName: "video-display-symbolic"
        label: "Project"
        tooltip: "Choose how to use connected displays (same as Meta+P)"
        available: backend.projectAvailable
        unavailableReason: backend.probed ? "Project needs qdbus6, which is not installed" : ""
        onToggled: {
            panel.closeRequested()
            backend.project()
        }
    }

    // ---- pages ----------------------------------------------------------------
    QQC2.StackView {
        id: stack
        anchors.fill: parent
        clip: true
        initialItem: mainPage

        readonly property int slide: 200
        pushEnter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: stack.width; to: 0; duration: stack.slide; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: stack.slide }
            }
        }
        pushExit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 0; to: -stack.width / 3; duration: stack.slide; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: stack.slide }
            }
        }
        popEnter: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: -stack.width / 3; to: 0; duration: stack.slide; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: stack.slide }
            }
        }
        popExit: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 0; to: stack.width; duration: stack.slide; easing.type: Easing.OutCubic }
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: stack.slide }
            }
        }
    }

    Component {
        id: wifiPage
        WifiPage {
            backend: panel.backend
            onBack: stack.pop()
        }
    }
    Component {
        id: bluetoothPage
        BluetoothPage {
            backend: panel.backend
            onBack: stack.pop()
        }
    }
    Component {
        id: audioPage
        AudioPage {
            backend: panel.backend
            onBack: stack.pop()
        }
    }

    Item {
        id: mainPage

        ColumnLayout {
            id: mainColumn
            anchors.fill: parent
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                visible: panel.editMode
                text: "Click a tile to show or hide it. Use the arrows to reorder."
                font: Kirigami.Theme.smallFont
                opacity: 0.7
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            GridLayout {
                id: grid
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                columns: 3
                columnSpacing: Kirigami.Units.largeSpacing
                rowSpacing: Kirigami.Units.largeSpacing

                Repeater {
                    model: panel.shownTiles

                    delegate: Item {
                        id: cell
                        required property string modelData
                        required property int index
                        readonly property TileDef def: panel.defs[modelData]
                        readonly property bool hidden: panel.hiddenTiles.indexOf(modelData) >= 0
                        readonly property bool usable: def.available && def.enabled

                        // Equal preferred widths + fillWidth = three equal columns.
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        implicitHeight: tile.implicitHeight

                        ToggleTile {
                            id: tile
                            anchors.fill: parent
                            iconName: cell.def.iconName
                            label: cell.def.label
                            tooltip: cell.def.tooltip
                            moreTooltip: cell.def.moreTooltip
                            checked: cell.def.checked && !panel.editMode
                            hasMore: cell.def.hasMore && !panel.editMode
                            enabled: cell.usable && !panel.editMode
                            opacity: panel.editMode ? (cell.hidden ? 0.3 : 1) : (enabled ? 1 : 0.4)
                            onToggled: cell.def.toggled()
                            onMoreClicked: cell.def.moreClicked()
                        }

                        // A disabled tile gets no hover events; explain here why it is disabled.
                        HoverHandler {
                            id: cellHover
                            enabled: !cell.usable && !panel.editMode
                        }
                        PlasmaComponents3.ToolTip {
                            text: !cell.def.available ? cell.def.unavailableReason : cell.def.disabledReason
                            visible: cellHover.hovered && text !== ""
                            delay: Kirigami.Units.toolTipDelay
                        }

                        // Edit mode: click = show/hide, arrows = reorder.
                        MouseArea {
                            id: editArea
                            anchors.fill: parent
                            visible: panel.editMode
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: panel.toggleHidden(cell.modelData)

                            PlasmaComponents3.ToolTip {
                                text: cell.hidden ? "Hidden. Click to show this tile" : "Click to hide this tile"
                                visible: editArea.containsMouse && !moveLeft.hovered && !moveRight.hovered
                                delay: Kirigami.Units.toolTipDelay
                            }
                            Kirigami.Icon {
                                anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: Kirigami.Units.smallSpacing }
                                width: Kirigami.Units.iconSizes.small
                                height: width
                                visible: cell.hidden
                                source: "view-hidden-symbolic"
                            }
                            PlasmaComponents3.ToolButton {
                                id: moveLeft
                                anchors { left: parent.left; top: parent.top }
                                visible: cell.index > 0
                                icon.name: "arrow-left-symbolic"
                                onClicked: panel.moveTile(cell.modelData, -1)
                                Accessible.name: "Move earlier"
                                PlasmaComponents3.ToolTip {
                                    text: "Move earlier"
                                    visible: moveLeft.hovered
                                    delay: Kirigami.Units.toolTipDelay
                                }
                            }
                            PlasmaComponents3.ToolButton {
                                id: moveRight
                                anchors { right: parent.right; top: parent.top }
                                visible: cell.index < panel.order.length - 1
                                icon.name: "arrow-right-symbolic"
                                onClicked: panel.moveTile(cell.modelData, 1)
                                Accessible.name: "Move later"
                                PlasmaComponents3.ToolTip {
                                    text: "Move later"
                                    visible: moveRight.hovered
                                    delay: Kirigami.Units.toolTipDelay
                                }
                            }
                        }
                    }
                }
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                visible: panel.shownTiles.length === 0
                text: "All tiles are hidden. Use the edit button below to show them again."
                opacity: 0.7
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.fillHeight: true }

            SliderRow {
                Layout.fillWidth: true
                visible: panel.backend.brightnessAvailable
                iconName: "video-display-brightness"
                iconTooltip: "Screen brightness"
                sliderTooltip: "Brightness"
                value: panel.backend.brightness
                onMoved: (value) => panel.backend.setBrightness(value)
            }
            SliderRow {
                Layout.fillWidth: true
                visible: panel.backend.volumeAvailable
                iconName: panel.backend.volumeIconName
                iconClickable: true
                iconTooltip: panel.backend.muted ? "Unmute" : "Mute"
                sliderTooltip: "Volume"
                value: panel.backend.volume
                hasMore: true
                moreTooltip: "Choose a sound output device"
                onMoved: (value) => panel.backend.setVolume(value)
                onIconClicked: panel.backend.toggleMute()
                onMoreClicked: stack.push(audioPage)
            }
            PlasmaComponents3.Label {
                Layout.fillWidth: true
                visible: panel.backend.probed && !panel.backend.volumeAvailable
                text: "No audio backend found (needs plasma-pa or wpctl)"
                font: Kirigami.Theme.smallFont
                opacity: 0.7
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.fillHeight: true }

            Footer {
                Layout.fillWidth: true
                hasBattery: panel.backend.hasBattery
                batteryIcon: panel.backend.batteryIconName
                batteryText: panel.backend.batteryStatusText
                editMode: panel.editMode
                onEditClicked: panel.editMode = !panel.editMode
                onSettingsClicked: {
                    panel.closeRequested()
                    panel.backend.openSystemSettings()
                }
            }
        }
    }
}
