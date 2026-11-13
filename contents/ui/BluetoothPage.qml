/*
 * Bluetooth sub-page: paired devices, click to connect / disconnect.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: page

    required property QtObject backend
    signal back()

    spacing: Kirigami.Units.smallSpacing

    Timer {
        interval: 4000
        repeat: true
        triggeredOnStart: true
        running: page.visible && page.backend.active && page.backend.btEnabled
        onTriggered: page.backend.refreshBtDevices()
    }

    PageHeader {
        Layout.fillWidth: true
        title: "Bluetooth"
        onBack: page.back()

        PlasmaComponents3.Switch {
            checked: page.backend.btEnabled
            enabled: !page.backend.airplaneMode
            onToggled: page.backend.setBluetooth(checked)
            Accessible.name: "Bluetooth"
        }
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        visible: page.backend.btError !== ""
        text: page.backend.btError
        textFormat: Text.PlainText
        color: Kirigami.Theme.negativeTextColor
        wrapMode: Text.Wrap
        font: Kirigami.Theme.smallFont
    }

    PlasmaComponents3.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: list
            clip: true
            model: page.backend.btEnabled ? page.backend.btDevices : []
            boundsBehavior: Flickable.StopAtBounds

            PlasmaComponents3.Label {
                anchors.centerIn: parent
                width: parent.width - Kirigami.Units.gridUnit * 2
                visible: list.count === 0
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                opacity: 0.7
                text: page.backend.airplaneMode ? "Airplane mode is on"
                    : !page.backend.btEnabled ? "Bluetooth is turned off"
                    : "No paired devices"
            }

            delegate: PlasmaComponents3.ItemDelegate {
                id: item
                required property var modelData
                readonly property bool busy: page.backend.btBusyMac === modelData.mac

                width: ListView.view.width
                highlighted: modelData.connected
                onClicked: page.backend.toggleBtDevice(modelData)
                Accessible.name: modelData.name

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing * 2

                    Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        source: item.modelData.connected ? "network-bluetooth-activated" : "network-bluetooth"
                        selected: item.highlighted
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: item.modelData.name
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            color: item.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }
                        PlasmaComponents3.Label {
                            Layout.fillWidth: true
                            text: item.busy ? (item.modelData.connected ? "Disconnecting…" : "Connecting…")
                                : item.modelData.connected ? "Connected · click to disconnect" : "Paired"
                            font: Kirigami.Theme.smallFont
                            opacity: 0.7
                            elide: Text.ElideRight
                            color: item.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }
                    }
                    PlasmaComponents3.BusyIndicator {
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        running: item.busy
                        visible: item.busy
                    }
                }

                PlasmaComponents3.ToolTip {
                    text: (item.modelData.connected ? "Disconnect from " : "Connect to ") + item.modelData.name
                    visible: item.hovered
                    delay: Kirigami.Units.toolTipDelay
                }
            }
        }
    }

    PlasmaComponents3.ToolButton {
        id: pairButton
        Layout.fillWidth: true
        icon.name: "list-add-symbolic"
        text: "Pair a new device…"
        onClicked: page.backend.openKcm("kcm_bluetooth")
        PlasmaComponents3.ToolTip {
            text: "Open the Bluetooth settings to pair a new device"
            visible: pairButton.hovered
            delay: Kirigami.Units.toolTipDelay
        }
    }
}
