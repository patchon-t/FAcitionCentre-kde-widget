/*
 * Accessibility sub-page, Windows 11 24H2 style ("Vision" section).
 *   Magnifier     -> KWin Zoom effect (zoom in to ~200% / back to 100%)
 *   Narrator      -> Orca screen reader
 *   Color filters -> KWin colour-blindness correction effect
 */
import QtQuick
import QtQuick.Layouts

Item {
    id: page

    required property QtObject backend
    signal back()
    signal openSettings()

    readonly property int preferredHeight: 386

    component SettingRow: Item {
        id: row
        property string glyph
        property string title
        property string subtitle
        property bool checked: false
        property string unavailableReason
        signal toggled()

        Layout.fillWidth: true
        implicitHeight: 60
        opacity: enabled ? 1 : 0.5

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            radius: WinTheme.controlRadius
            color: area.pressed ? WinTheme.subtlePressed : area.containsMouse ? WinTheme.subtleHover : "transparent"
            Behavior on color { ColorAnimation { duration: WinTheme.fast } }
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: row.toggled()
        }
        FluentIcon {
            id: icon
            x: 20
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            glyph: row.glyph
        }
        Column {
            anchors { left: icon.right; leftMargin: 14; right: state.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
            WinText { width: parent.width; text: row.title }
            WinText { width: parent.width; text: row.subtitle; font.pixelSize: WinTheme.caption; color: WinTheme.textSecondary }
        }
        WinText {
            id: state
            anchors { right: toggle.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
            text: row.checked ? "On" : "Off"
        }
        WinToggleSwitch {
            id: toggle
            anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
            checked: row.checked
            accessibleName: row.title
            onToggled: row.toggled()
        }
        HoverHandler { id: disabledHover; enabled: !row.enabled }
        WinToolTip { text: row.unavailableReason; shown: disabledHover.hovered }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        PageHeader {
            Layout.fillWidth: true
            title: "Accessibility"
            onBack: page.back()
        }
        WinText {
            Layout.leftMargin: 20
            Layout.topMargin: 6
            Layout.bottomMargin: 4
            text: "Vision"
            font.weight: Font.DemiBold
        }
        SettingRow {
            glyph: "magnifier"
            title: "Magnifier"
            subtitle: "See words and images better"
            checked: page.backend.magnifierOn
            enabled: page.backend.magnifierAvailable
            unavailableReason: "Needs qdbus6 to control KWin's Zoom effect"
            onToggled: page.backend.setMagnifier(!page.backend.magnifierOn)
        }
        SettingRow {
            glyph: "narrator"
            title: "Narrator"
            subtitle: "Screen reader (Orca)"
            checked: page.backend.narratorOn
            enabled: page.backend.narratorAvailable
            unavailableReason: "Install the Orca screen reader (package: orca)"
            onToggled: page.backend.setNarrator(!page.backend.narratorOn)
        }
        SettingRow {
            glyph: "color-filter"
            title: "Color filters"
            subtitle: "Distinguish among colors easily"
            checked: page.backend.colorFilterOn
            enabled: page.backend.colorFilterAvailable
            unavailableReason: "Needs KWin's colour-blindness correction effect (Plasma 6.1 or later)"
            onToggled: page.backend.setColorFilter(!page.backend.colorFilterOn)
        }
        Item { Layout.fillHeight: true }
        PageFooter {
            Layout.fillWidth: true
            text: "More Accessibility settings"
            onClicked: page.openSettings()
        }
    }
}
