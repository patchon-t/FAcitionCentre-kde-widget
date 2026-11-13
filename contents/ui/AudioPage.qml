/*
 * Audio sub-page: pick the default output device.
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

    // Only needed for the wpctl fallback; the QML plugin pushes changes itself.
    Timer {
        interval: 3000
        repeat: true
        triggeredOnStart: true
        running: page.visible && page.backend.active && !page.backend.volumeUsesPlugin
        onTriggered: page.backend.refreshSinks()
    }

    PageHeader {
        Layout.fillWidth: true
        title: "Sound output"
        onBack: page.back()
    }

    PlasmaComponents3.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: list
            clip: true
            model: page.backend.sinks
            boundsBehavior: Flickable.StopAtBounds

            PlasmaComponents3.Label {
                anchors.centerIn: parent
                visible: list.count === 0
                opacity: 0.7
                text: "No output devices found"
            }

            delegate: PlasmaComponents3.ItemDelegate {
                id: item
                required property var modelData

                width: ListView.view.width
                highlighted: modelData.isDefault
                onClicked: page.backend.setDefaultSink(modelData)
                Accessible.name: modelData.name

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing * 2

                    Kirigami.Icon {
                        implicitWidth: Kirigami.Units.iconSizes.smallMedium
                        implicitHeight: Kirigami.Units.iconSizes.smallMedium
                        source: "audio-speakers-symbolic"
                        fallback: "audio-card"
                        selected: item.highlighted
                    }
                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: item.modelData.name
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: item.highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                    }
                    Kirigami.Icon {
                        visible: item.modelData.isDefault
                        implicitWidth: Kirigami.Units.iconSizes.small
                        implicitHeight: Kirigami.Units.iconSizes.small
                        source: "checkmark-symbolic"
                        fallback: "dialog-ok"
                        selected: item.highlighted
                    }
                }

                PlasmaComponents3.ToolTip {
                    text: item.modelData.isDefault ? item.modelData.name + " (current output)" : "Switch output to " + item.modelData.name
                    visible: item.hovered
                    delay: Kirigami.Units.toolTipDelay
                }
            }
        }
    }
}
