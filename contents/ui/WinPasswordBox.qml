/*
 * Windows 11 PasswordBox: 32 px field, accent underline when focused, reveal button.
 */
import QtQuick

Rectangle {
    id: box

    property alias text: input.text
    property string placeholder: "Password"
    signal accepted()
    signal cancelled()

    function focusInput() { input.forceActiveFocus() }

    implicitWidth: 200
    implicitHeight: 32
    radius: WinTheme.controlRadius
    color: input.activeFocus ? (WinTheme.dark ? "#1e1e1e" : "#ffffff") : area.containsMouse ? WinTheme.controlHover : WinTheme.control
    border.width: 1
    border.color: WinTheme.controlStroke

    Rectangle {   // bottom line: accent 2 px when focused
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 1; rightMargin: 1 }
        height: input.activeFocus ? 2 : 1
        color: input.activeFocus ? WinTheme.accent : WinTheme.textSecondary
        opacity: input.activeFocus ? 1 : 0.5
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
        onPressed: input.forceActiveFocus()
    }
    TextInput {
        id: input
        anchors { left: parent.left; right: reveal.left; leftMargin: 11; rightMargin: 4; verticalCenter: parent.verticalCenter }
        color: WinTheme.text
        selectionColor: WinTheme.accent
        selectedTextColor: WinTheme.textOnAccent
        font.family: WinTheme.fontFamily
        font.pixelSize: WinTheme.body
        echoMode: reveal.down ? TextInput.Normal : TextInput.Password
        passwordCharacter: "●"
        clip: true
        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
        onAccepted: box.accepted()
        Keys.onEscapePressed: box.cancelled()

        WinText {
            anchors.fill: parent
            visible: input.text === ""
            text: box.placeholder
            color: WinTheme.textTertiary
        }
    }
    Rectangle {
        id: reveal
        readonly property bool down: revealArea.pressed
        visible: input.text !== ""
        anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
        width: 28
        height: 24
        radius: WinTheme.controlRadius
        color: revealArea.pressed ? WinTheme.subtlePressed : revealArea.containsMouse ? WinTheme.subtleHover : "transparent"
        FluentIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            glyph: "eye"
            color: WinTheme.textSecondary
        }
        MouseArea {
            id: revealArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
