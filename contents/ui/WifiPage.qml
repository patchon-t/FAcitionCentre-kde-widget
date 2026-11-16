/*
 * Wi-Fi sub-page, Windows 11 24H2 style: header with toggle and scan
 * progress, networks list; click a network to expand it:
 *   connected  -> (i) Properties + Disconnect
 *   other      -> [x] Connect automatically + Connect
 *   needs key  -> Enter the password, Next / Cancel
 */
import QtQuick
import QtQuick.Layouts

Item {
    id: page

    required property QtObject backend
    signal back()
    signal openSettings()

    readonly property int preferredHeight: 448

    property string selectedSsid: ""
    property string passwordSsid: ""
    property bool autoConnect: true

    function connect(net) {
        if (page.backend.wifiBusySsid !== "") {
            return
        }
        passwordSsid = page.backend.connectWifi(net, undefined, autoConnect) ? net.ssid : ""
    }
    function submit(net, password) {
        if (password === "") {
            return
        }
        passwordSsid = ""
        page.backend.connectWifi(net, password, autoConnect)
    }
    function status(net, busy) {
        if (busy) {
            return net.inUse ? "Disconnecting" : "Connecting"
        }
        if (net.inUse) {
            const c = page.backend.connectivity
            const base = (c === "limited" || c === "none" || c === "portal") ? "No internet" : "Connected"
            return base + (net.secured ? ", secured" : "")
        }
        return net.secured ? "Secured" : "Open"
    }

    // Rescan while showing; paused during password entry so the list isn't rebuilt under the user.
    Timer {
        interval: 8000
        repeat: true
        triggeredOnStart: true
        running: page.visible && page.backend.active && page.backend.wifiEnabled && page.passwordSsid === ""
        onTriggered: page.backend.scanWifi()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PageHeader {
            Layout.fillWidth: true
            title: "Wi-Fi"
            busy: page.backend.wifiScanning
            onBack: page.back()
            WinToggleSwitch {
                checked: page.backend.wifiEnabled
                enabled: !page.backend.airplaneMode
                accessibleName: "Wi-Fi"
                onToggled: page.backend.setWifi(!page.backend.wifiEnabled)
            }
        }

        WinText {
            Layout.fillWidth: true
            Layout.leftMargin: 24
            Layout.rightMargin: 24
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            visible: page.backend.wifiError !== ""
            text: page.backend.wifiError
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
            Layout.topMargin: 4

            ListView {
                id: list
                anchors.fill: parent
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: page.backend.wifiEnabled ? page.backend.wifiNetworks : []

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
                        : !page.backend.wifiEnabled ? "Wi-Fi is turned off"
                        : page.backend.wifiScanning ? "" : "No Wi-Fi networks found"
                }

                delegate: WinListItem {
                    id: entry
                    required property var modelData
                    readonly property bool connected: modelData.inUse
                    readonly property bool prompting: page.passwordSsid === modelData.ssid

                    width: ListView.view.width
                    glyph: page.backend.wifiGlyphFor(modelData.signal)
                    badgeGlyph: modelData.secured ? "lock" : ""
                    title: modelData.ssid
                    subtitle: (connected || expanded || busy) ? page.status(modelData, busy) : ""
                    busy: page.backend.wifiBusySsid === modelData.ssid
                    expanded: page.selectedSsid === modelData.ssid
                    showInfo: connected
                    tooltip: modelData.ssid + "\nSignal " + modelData.signal + "%" + (modelData.security !== "" ? "\n" + modelData.security : "")
                    onInfoClicked: page.openSettings()
                    onClicked: {
                        page.selectedSsid = expanded ? "" : modelData.ssid
                        page.passwordSsid = ""
                        page.autoConnect = true
                    }

                    // --- expanded: password entry ---
                    WinText {
                        visible: entry.prompting
                        text: "Enter the password"
                    }
                    WinPasswordBox {
                        id: password
                        visible: entry.prompting
                        Layout.fillWidth: true
                        placeholder: ""
                        onAccepted: page.submit(entry.modelData, text)
                        onCancelled: page.passwordSsid = ""
                        onVisibleChanged: if (visible) { text = ""; focusInput() }
                    }
                    RowLayout {
                        visible: entry.prompting
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 8
                        WinButton {
                            Layout.fillWidth: true
                            accent: true
                            text: "Next"
                            enabled: password.text.length >= 8 || (password.text.length > 0 && entry.modelData.security.indexOf("WEP") >= 0)
                            onClicked: page.submit(entry.modelData, password.text)
                        }
                        WinButton {
                            Layout.fillWidth: true
                            text: "Cancel"
                            onClicked: page.passwordSsid = ""
                        }
                    }

                    // --- expanded: connect / disconnect ---
                    WinCheckBox {
                        visible: !entry.prompting && !entry.connected
                        text: "Connect automatically"
                        checked: page.autoConnect
                        onToggled: page.autoConnect = !page.autoConnect
                    }
                    RowLayout {
                        visible: !entry.prompting
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        WinButton {
                            Layout.preferredWidth: entry.connected ? 148 : 150
                            accent: !entry.connected
                            enabled: !entry.busy
                            text: entry.connected ? "Disconnect" : "Connect"
                            onClicked: page.connect(entry.modelData)
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
            text: "More Wi-Fi settings"
            onClicked: page.openSettings()
            WinIconButton {
                width: 32
                height: 32
                glyph: "refresh"
                tooltip: "Refresh"
                enabled: page.backend.wifiEnabled && !page.backend.wifiScanning
                onClicked: page.backend.scanWifi()
            }
        }
    }
}
