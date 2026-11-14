/*
 * Flyout surface: 8 px radius, hairline border and a soft drop shadow
 * (built from stacked translucent rectangles, so it needs no graphics effects).
 */
import QtQuick

Rectangle {
    id: card

    radius: WinTheme.cardRadius
    color: WinTheme.flyout
    border.width: 1
    border.color: WinTheme.cardStroke

    Repeater {
        model: 8
        Rectangle {
            required property int index
            z: -1
            anchors.fill: parent
            anchors.margins: -(index + 1) * 1.25
            anchors.topMargin: -(index + 1) * 0.6
            anchors.bottomMargin: -(index + 1) * 1.6
            radius: card.radius + (index + 1) * 1.25
            color: WinTheme.a(WinTheme.shadow, WinTheme.dark ? 0.06 : 0.025)
        }
    }
}
