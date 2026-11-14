/*
 * Bluetooth sub-page, Windows 11 style: paired devices; click to expand,
 * then Connect / Disconnect.
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
        if (/mouse|mx (master|anywhere)|trackpad/.test(n)) return "mouse"
        if (/keyboard|keys|k\d{3}/.test(n)) return "keyboard"
        if (/phone|pixel|galaxy|iphone|redmi|oneplus|xiaomi/.test(n)) return "phone"
        if (/speaker|soundbar|jbl|boom/.test(n)) return "speaker-device"
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
            Layout.bottomMargin: 8
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
            Layout.leftMargin: 8
            Layout.rightMargin: 8

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: page.backend.btEnabled ? page.backend.btDevices : []

                HoverHandler { id: listHover }

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
                    subtitle: busy ? (modelData.connected ? "Disconnecting…" : "Connecting…")
                            : modelData.connected ? "Connected" : "Paired"
                    busy: page.backend.btBusyMac === modelData.mac
                    expanded: page.selectedMac === modelData.mac
                    tooltip: modelData.name + " (" + modelData.mac + ")"
                    onClicked: page.selectedMac = expanded ? "" : modelData.mac

                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        WinButton {
                            accent: !entry.modelData.connected
                            enabled: !entry.busy
                            implicitWidth: 120
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
