/*
 * Windows 11 slider row: icon button, slider, optional chevron button.
 */
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: row

    property string glyph
    property real value: 0
    property bool iconClickable: false
    property string iconTooltip
    property string sliderName
    property bool hasMore: false
    property string moreTooltip

    signal moved(real value)
    signal iconClicked()
    signal moreClicked()

    spacing: 2
    implicitHeight: 40

    WinIconButton {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        glyph: row.glyph
        tooltip: row.iconTooltip
        interactive: row.iconClickable   // brightness icon is just an icon
        onClicked: row.iconClicked()
    }
    WinSlider {
        Layout.fillWidth: true
        // Pull the track towards the icons (the thumb's half-width is inset).
        Layout.leftMargin: -8
        Layout.rightMargin: -8
        value: row.value
        accessibleName: row.sliderName
        onMoved: (v) => row.moved(v)
    }
    WinIconButton {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        opacity: row.hasMore ? 1 : 0
        enabled: row.hasMore
        glyph: "chevron-right"
        tooltip: row.moreTooltip
        onClicked: row.moreClicked()
    }
}
