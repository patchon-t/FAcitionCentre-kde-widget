/*
 * Sound output sub-page, Windows 11 style: pick the default output device.
 */
import QtQuick
import QtQuick.Layouts

Item {
    id: page

    required property QtObject backend
    signal back()
    signal openSettings()

    readonly property int preferredHeight: Math.max(304, Math.min(448, 56 + 16 + list.count * 54 + WinTheme.footerHeight))

    // Only needed for the wpctl fallback; the QML plugin pushes changes itself.
    Timer {
        interval: 3000
        repeat: true
        triggeredOnStart: true
        running: page.visible && page.backend.active && !page.backend.volumeUsesPlugin
        onTriggered: page.backend.refreshSinks()
    }

    function deviceGlyph(name) {
        return /head|bud|ear|airpod/i.test(String(name)) ? "headphones" : "speaker-device"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PageHeader {
            Layout.fillWidth: true
            title: "Sound output"
            onBack: page.back()
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
                model: page.backend.sinks

                HoverHandler { id: listHover }

                WinText {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    color: WinTheme.textSecondary
                    text: "No output devices found"
                }

                delegate: WinListItem {
                    required property var modelData
                    width: ListView.view.width
                    glyph: page.deviceGlyph(modelData.name)
                    title: modelData.name
                    selected: modelData.isDefault
                    tooltip: modelData.isDefault ? modelData.name + " (current output)" : "Switch output to " + modelData.name
                    onClicked: page.backend.setDefaultSink(modelData)
                }
            }

            WinScrollIndicator {
                flickable: list
                hovered: listHover.hovered
            }
        }

        PageFooter {
            Layout.fillWidth: true
            text: "More volume settings"
            onClicked: page.openSettings()
        }
    }
}
