/*
 * Windows 11 standard / accent button (32 px high, 4 px radius).
 */
import QtQuick

Rectangle {
    id: button

    property string text
    property bool accent: false
    property string glyph
    signal clicked()

    implicitWidth: Math.max(96, row.implicitWidth + 24)
    implicitHeight: 32
    radius: WinTheme.controlRadius
    color: {
        if (accent) {
            return !enabled ? WinTheme.controlDisabled : area.pressed ? WinTheme.accentPressed : area.containsMouse ? WinTheme.accentHover : WinTheme.accent
        }
        return !enabled ? WinTheme.controlDisabled : area.pressed ? WinTheme.controlPressed : area.containsMouse ? WinTheme.controlHover : WinTheme.control
    }
    border.width: accent && enabled ? 0 : 1
    border.color: activeFocus ? WinTheme.text : WinTheme.controlStroke
    Behavior on color { ColorAnimation { duration: WinTheme.fast } }

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: button.clicked()
    Keys.onSpacePressed: button.clicked()
    Keys.onReturnPressed: button.clicked()

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
        FluentIcon {
            visible: button.glyph !== ""
            anchors.verticalCenter: parent.verticalCenter
            glyph: button.glyph
            color: label.color
        }
        WinText {
            id: label
            text: button.text
            color: !button.enabled ? WinTheme.textDisabled
                 : button.accent ? WinTheme.textOnAccent
                 : area.pressed ? WinTheme.textSecondary : WinTheme.text
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
    }
}
