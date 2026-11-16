/*
 * Project sub-page, Windows 11 style: PC screen only / Duplicate / Extend /
 * Second screen only, applied through kscreen (same presets as Meta+P).
 */
import QtQuick
import QtQuick.Layouts

Item {
    id: page

    required property QtObject backend
    signal back()
    signal openSettings()

    readonly property int preferredHeight: 386

    Component.onCompleted: backend.refreshDisplay()

    component KeyCap: Rectangle {
        property string text
        implicitWidth: Math.max(20, label.implicitWidth + 10)
        implicitHeight: 20
        radius: 3
        color: WinTheme.control
        border.width: 1
        border.color: WinTheme.controlStroke
        WinText { id: label; anchors.centerIn: parent; text: parent.text; font.pixelSize: 11; color: WinTheme.textSecondary }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PageHeader {
            Layout.fillWidth: true
            title: "Project"
            onBack: page.back()
            KeyCap { text: "Meta" }
            KeyCap { text: "P" }
        }

        Repeater {
            model: [
                { mode: "pc", glyph: "display-pc", label: "PC screen only" },
                { mode: "duplicate", glyph: "display-duplicate", label: "Duplicate" },
                { mode: "extend", glyph: "display-extend", label: "Extend" },
                { mode: "second", glyph: "display-second", label: "Second screen only" }
            ]
            delegate: WinListItem {
                required property var modelData
                Layout.fillWidth: true
                Layout.leftMargin: 4
                Layout.rightMargin: 4
                glyph: modelData.glyph
                title: modelData.label
                selected: page.backend.displayMode === modelData.mode
                enabled: page.backend.displayModesAvailable
                tooltip: page.backend.displayCount < 2 && modelData.mode !== "pc" ? "Connect a second display to use this" : ""
                onClicked: page.backend.setDisplayMode(modelData.mode)
            }
        }
        Item { Layout.fillHeight: true }
        PageFooter {
            Layout.fillWidth: true
            text: "More Display settings"
            onClicked: page.openSettings()
        }
    }
}
