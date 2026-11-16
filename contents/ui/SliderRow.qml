/*
 * Windows 11 slider row, positioned like the 24H2 flyout (360 px card):
 * icon centred at x 32, track from x 56 to x 301, output button at x 305..349.
 */
import QtQuick

Item {
    id: row

    property string glyph
    property real value: 0
    property bool iconClickable: false
    property string iconTooltip
    property string sliderName
    property bool hasMore: false
    property string moreGlyph: "sound-output"
    property string moreTooltip

    signal moved(real value)
    signal iconClicked()
    signal moreClicked()

    implicitWidth: WinTheme.flyoutWidth
    implicitHeight: 40

    WinIconButton {
        x: 12
        width: 40
        height: 40
        glyph: row.glyph
        tooltip: row.iconTooltip
        interactive: row.iconClickable   // brightness icon is just an icon
        onClicked: row.iconClicked()
    }
    WinSlider {
        x: 46
        width: 265
        anchors.verticalCenter: parent.verticalCenter
        value: row.value
        accessibleName: row.sliderName
        onMoved: (v) => row.moved(v)
    }
    Rectangle {
        id: more
        visible: row.hasMore
        x: 305
        width: 44
        height: 36
        anchors.verticalCenter: parent.verticalCenter
        radius: WinTheme.controlRadius
        color: moreArea.pressed ? WinTheme.subtlePressed : moreArea.containsMouse ? WinTheme.subtleHover : "transparent"
        Behavior on color { ColorAnimation { duration: WinTheme.fast } }
        activeFocusOnTab: true
        border.width: activeFocus ? 2 : 0
        border.color: WinTheme.text
        Keys.onReturnPressed: row.moreClicked()
        Keys.onSpacePressed: row.moreClicked()
        Accessible.role: Accessible.Button
        Accessible.name: row.moreTooltip

        Row {
            anchors.centerIn: parent
            spacing: 2
            FluentIcon { anchors.verticalCenter: parent.verticalCenter; glyph: row.moreGlyph }
            FluentIcon { anchors.verticalCenter: parent.verticalCenter; width: 10; height: 10; glyph: "chevron-right" }
        }
        MouseArea {
            id: moreArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: row.moreClicked()
        }
        WinToolTip {
            text: row.moreTooltip
            shown: moreArea.containsMouse
        }
    }
}
