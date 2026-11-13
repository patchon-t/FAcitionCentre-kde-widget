/*
 * Wi-Fi sub-page: available networks, click to connect / disconnect,
 * inline password prompt for secured networks without a saved profile.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: page

    required property QtObject backend
    signal back()

    // SSID currently showing the password prompt ("" = none).
    property string passwordSsid: ""

    spacing: Kirigami.Units.smallSpacing

    function activate(net) {
        if (backend.wifiBusySsid !== "") {
            return
        }
        passwordSsid = backend.connectWifi(net) ? net.ssid : ""
    }
    function submit(net, password) {
        if (password === "") {
            return
        }
        passwordSsid = ""
        backend.connectWifi(net, password)
    }
    function signalIcon(net) {
        return backend.wifiIconForSignal(net.signal)
    }

    // Rescan while the page is showing. Paused during password entry so the
    // list (and the text field in it) is not rebuilt under the user.
    Timer {
        interval: 8000
        repeat: true
        triggeredOnStart: true
        running: page.visible && page.backend.active && page.backend.wifiEnabled && page.passwordSsid === ""
        onTriggered: page.backend.scanWifi()
    }

    PageHeader {
        Layout.fillWidth: true
        title: "Wi-Fi"
        onBack: page.back()

        PlasmaComponents3.BusyIndicator {
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            running: page.backend.wifiScanning
            visible: running
        }
        PlasmaComponents3.Switch {
            checked: page.backend.wifiEnabled
            enabled: !page.backend.airplaneMode
            onToggled: page.backend.setWifi(checked)
            Accessible.name: "Wi-Fi"
        }
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        visible: page.backend.wifiError !== ""
        text: page.backend.wifiError
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
            model: page.backend.wifiEnabled ? page.backend.wifiNetworks : []
            boundsBehavior: Flickable.StopAtBounds

            PlasmaComponents3.Label {
                anchors.centerIn: parent
                width: parent.width - Kirigami.Units.gridUnit * 2
                visible: list.count === 0
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                opacity: 0.7
                text: page.backend.airplaneMode ? "Airplane mode is on"
                    : !page.backend.wifiEnabled ? "Wi-Fi is turned off"
                    : page.backend.wifiScanning ? "Searching for networks…"
                    : "No networks found"
            }

            delegate: ColumnLayout {
                id: entry
                required property var modelData
                readonly property bool busy: page.backend.wifiBusySsid === modelData.ssid
                readonly property bool prompting: page.passwordSsid === modelData.ssid

                width: ListView.view.width
                spacing: 0

                PlasmaComponents3.ItemDelegate {
                    id: item
                    Layout.fillWidth: true
                    highlighted: entry.modelData.inUse
                    onClicked: page.activate(entry.modelData)
                    Accessible.name: entry.modelData.ssid

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing * 2

                        Kirigami.Icon {
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            source: page.signalIcon(entry.modelData)
                            fallback: "network-wireless"
                            selected: item.highlighted
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: entry.modelData.ssid
                                textFormat: Text.PlainText
                                elide: Text.ElideRight
                                color: item.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            }
                            PlasmaComponents3.Label {
                                Layout.fillWidth: true
                                text: entry.busy ? (entry.modelData.inUse ? "Disconnecting…" : "Connecting…")
                                    : entry.modelData.inUse ? "Connected · click to disconnect"
                                    : (entry.modelData.saved ? "Saved" : entry.modelData.secured ? "Secured" : "Open")
                                      + " · " + entry.modelData.signal + "%"
                                font: Kirigami.Theme.smallFont
                                opacity: 0.7
                                elide: Text.ElideRight
                                color: item.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            }
                        }
                        PlasmaComponents3.BusyIndicator {
                            implicitWidth: Kirigami.Units.iconSizes.smallMedium
                            implicitHeight: Kirigami.Units.iconSizes.smallMedium
                            running: entry.busy
                            visible: entry.busy
                        }
                        Kirigami.Icon {
                            visible: entry.modelData.secured && !entry.busy
                            implicitWidth: Kirigami.Units.iconSizes.small
                            implicitHeight: Kirigami.Units.iconSizes.small
                            source: "object-locked-symbolic"
                            selected: item.highlighted
                        }
                    }

                    PlasmaComponents3.ToolTip {
                        text: entry.modelData.inUse ? "Disconnect from " + entry.modelData.ssid
                                                    : "Connect to " + entry.modelData.ssid
                              + (entry.modelData.secured ? " (" + entry.modelData.security + ")" : "")
                        visible: item.hovered
                        delay: Kirigami.Units.toolTipDelay
                    }
                }

                RowLayout {
                    visible: entry.prompting
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.largeSpacing
                    Layout.rightMargin: Kirigami.Units.largeSpacing
                    Layout.bottomMargin: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing

                    onVisibleChanged: {
                        if (visible) {
                            passwordField.text = ""
                            passwordField.forceActiveFocus()
                        }
                    }

                    PlasmaComponents3.TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        placeholderText: "Password"
                        echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                        onAccepted: page.submit(entry.modelData, text)
                        Keys.onEscapePressed: page.passwordSsid = ""
                    }
                    PlasmaComponents3.ToolButton {
                        id: showPassword
                        checkable: true
                        icon.name: checked ? "password-show-off" : "password-show-on"
                        Accessible.name: "Show password"
                        PlasmaComponents3.ToolTip {
                            text: "Show password"
                            visible: showPassword.hovered
                            delay: Kirigami.Units.toolTipDelay
                        }
                    }
                    PlasmaComponents3.Button {
                        text: "Connect"
                        enabled: passwordField.text.length >= 8 || (passwordField.text.length > 0 && entry.modelData.security.indexOf("WEP") >= 0)
                        onClicked: page.submit(entry.modelData, passwordField.text)
                    }
                }
            }
        }
    }
}
