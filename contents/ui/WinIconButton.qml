/*
 * Subtle (transparent until hovered) icon button, as in the Windows 11
 * flyout footer and slider rows.
 */
import QtQuick

Rectangle {
    id: button

    property string glyph
    property string tooltip
    property color iconColor: WinTheme.text
    property int iconSize: WinTheme.iconSize
    property bool hasFocusRing: true
    // false = plain icon: no hover fill, no click (tooltip still shows)
    property bool interactive: true

    signal clicked()

    implicitWidth: 36
    implicitHeight: 36
    radius: WinTheme.controlRadius
    color: !enabled || !interactive ? "transparent" : area.pressed ? WinTheme.subtlePressed : area.containsMouse ? WinTheme.subtleHover : "transparent"
    Behavior on color { ColorAnimation { duration: WinTheme.fast } }
    border.width: activeFocus && hasFocusRing ? 2 : 0
    border.color: WinTheme.text

    activeFocusOnTab: interactive
    Accessible.role: Accessible.Button
    Accessible.name: tooltip
    Accessible.onPressAction: button.clicked()
    Keys.onSpacePressed: button.clicked()
    Keys.onReturnPressed: button.clicked()

    FluentIcon {
        anchors.centerIn: parent
        width: button.iconSize
        height: button.iconSize
        glyph: button.glyph
        color: button.enabled ? button.iconColor : WinTheme.textDisabled
        opacity: area.pressed && button.interactive ? 0.8 : 1
        scale: area.pressed && button.interactive ? 0.9 : 1
        Behavior on scale { NumberAnimation { duration: WinTheme.fast } }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: if (button.interactive) button.clicked()
    }
    WinToolTip {
        text: button.tooltip
        shown: area.containsMouse
    }
}
