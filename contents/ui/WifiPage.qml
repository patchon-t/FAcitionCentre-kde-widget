/*
 * Wi-Fi sub-page, Windows 11 style: header with toggle, list of networks;
 * click a network to expand it (Connect / Disconnect, security key prompt).
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

    function connect(net) {
        if (page.backend.wifiBusySsid !== "") {
            return
        }
        passwordSsid = page.backend.connectWifi(net) ? net.ssid : ""
    }
    function submit(net, password) {
        if (password === "") {
            return
        }
        passwordSsid = ""
        page.backend.connectWifi(net, password)
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
            onBack: page.back()
            Spinner {
                width: 16
                height: 16
                running: page.backend.wifiScanning
            }
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
            Layout.bottomMargin: 8
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
            Layout.leftMargin: 8
            Layout.rightMargin: 8

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
                        : page.backend.wifiScanning ? "Looking for networks…"
                        : "No Wi-Fi networks found"
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
                    subtitle: busy ? (connected ? "Disconnecting…" : "Connecting…")
                            : connected ? (modelData.secured ? "Connected, secured" : "Connected")
                            : modelData.secured ? "Secured" : "Open"
                    busy: page.backend.wifiBusySsid === modelData.ssid
                    expanded: page.selectedSsid === modelData.ssid
                    tooltip: modelData.ssid + " · signal " + modelData.signal + "%" + (modelData.security !== "" ? " · " + modelData.security : "")
                    onClicked: {
                        page.selectedSsid = expanded ? "" : modelData.ssid
                        page.passwordSsid = ""
                    }

                    // --- expanded content ---
                    WinText {
                        visible: entry.prompting
                        text: "Enter the network security key"
                        font.pixelSize: WinTheme.caption
                        color: WinTheme.textSecondary
                    }
                    WinPasswordBox {
                        id: password
                        visible: entry.prompting
                        Layout.fillWidth: true
                        placeholder: "Network security key"
                        onAccepted: page.submit(entry.modelData, text)
                        onCancelled: page.passwordSsid = ""
                        onVisibleChanged: if (visible) { text = ""; focusInput() }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Item { Layout.fillWidth: true }
                        WinButton {
                            visible: entry.prompting
                            text: "Cancel"
                            onClicked: page.passwordSsid = ""
                        }
                        WinButton {
                            visible: entry.prompting
                            accent: true
                            text: "Next"
                            enabled: password.text.length >= 8 || (password.text.length > 0 && entry.modelData.security.indexOf("WEP") >= 0)
                            onClicked: page.submit(entry.modelData, password.text)
                        }
                        WinButton {
                            visible: !entry.prompting
                            accent: !entry.connected
                            enabled: !entry.busy
                            text: entry.connected ? "Disconnect" : "Connect"
                            implicitWidth: 120
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
        }
    }
}
