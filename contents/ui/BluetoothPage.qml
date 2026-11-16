/*
 * Bluetooth sub-page, Windows 11 24H2 style: "Your devices" with status and
 * battery level; click a device to expand it, then Connect / Disconnect.
 */
import QtQuick
import QtQuick.Layouts

Item {
    id: page

    required property QtObject backend
    signal back()
    signal openSettings()

    readonly property int preferredHeight: 448
    property string selectedMac: ""

    function deviceGlyph(name) {
        const n = String(name).toLowerCase()
        if (/head|bud|ear|airpod|wh-|wf-|jabra|bose|sony|beats|qc\d/.test(n)) return "headphones"
        if (/mouse|mx (master|anywhere)|trackpad|logi m|m\d{3}\b/.test(n)) return "mouse"
        if (/keyboard|keys|k\d{3}/.test(n)) return "keyboard"
        if (/phone|pixel|galaxy|iphone|redmi|oneplus|xiaomi|oppo|vivo|reno/.test(n)) return "phone"
        if (/speaker|soundbar|jbl|boom|音响|音响/.test(n)) return "speaker-device"
        return "device"
    }

    Timer {
        interval: 4000
        repeat: true
        triggeredOnStart: true
        running: page.visible && page.backend.active && page.backend.btEnabled
        onTriggered: page.backend.refreshBtDevices()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PageHeader {
            Layout.fillWidth: true
            title: "Bluetooth"
            busy: page.backend.btRefreshing && page.backend.btDevices.length === 0
            onBack: page.back()
            WinToggleSwitch {
                checked: page.backend.btEnabled
                enabled: !page.backend.airplaneMode
                accessibleName: "Bluetooth"
                onToggled: page.backend.setBluetooth(!page.backend.btEnabled)
            }
        }

        WinText {
            Layout.fillWidth: true
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            Layout.topMargin: 4
            visible: page.backend.btError !== ""
            text: page.backend.btError
            color: WinTheme.critical
            font.pixelSize: WinTheme.caption
            wrapMode: Text.Wrap
            maximumLineCount: 3
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: page.backend.btEnabled ? page.backend.btDevices : []

                HoverHandler { id: listHover }

                header: WinText {
                    visible: list.count > 0
                    height: visible ? 40 : 0
                    leftPadding: 16
                    text: "Your devices"
                    font.weight: Font.DemiBold
                }

                WinText {
                    anchors.centerIn: parent
                    width: parent.width - 48
                    visible: list.count === 0
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    color: WinTheme.textSecondary
                    text: page.backend.airplaneMode ? "Airplane mode is on"
                        : !page.backend.btEnabled ? "Bluetooth is turned off"
                        : "No paired devices"
                }

                delegate: WinListItem {
                    id: entry
                    required property var modelData

                    width: ListView.view.width
                    glyph: page.deviceGlyph(modelData.name)
                    title: modelData.name
                    subtitle: busy ? (modelData.connected ? "Disconnecting" : "Connecting")
                            : modelData.connected ? "Connected" : "Not connected"
                    trailingText: modelData.battery >= 0 ? modelData.battery + "%" : ""
                    trailingBattery: modelData.battery
                    busy: page.backend.btBusyMac === modelData.mac
                    expanded: page.selectedMac === modelData.mac
                    tooltip: modelData.name + "\n" + modelData.mac
                    onClicked: page.selectedMac = expanded ? "" : modelData.mac

                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        WinButton {
                            accent: !entry.modelData.connected
                            enabled: !entry.busy
                            Layout.preferredWidth: 148
                            text: entry.modelData.connected ? "Disconnect" : "Connect"
                            onClicked: page.backend.toggleBtDevice(entry.modelData)
                        }
                    }
                }
            }

            WinScrollIndicator {
                flickable: list
                hovered: listHover.hovered
            }
        }

        PageFooter {
            Layout.fillWidth: true
            text: "More Bluetooth settings"
            onClicked: page.openSettings()
        }
    }
}
