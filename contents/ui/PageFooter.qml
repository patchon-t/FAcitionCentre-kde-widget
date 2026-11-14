/*
 * Sub-page footer content: a "More ... settings" link, like Windows 11.
 */
import QtQuick

Item {
    id: footer

    property string text
    signal clicked()

    implicitHeight: WinTheme.footerHeight

    Rectangle {
        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
        width: label.implicitWidth + 24
        height: 32
        radius: WinTheme.controlRadius
        color: area.pressed ? WinTheme.subtlePressed : area.containsMouse ? WinTheme.subtleHover : "transparent"
        Behavior on color { ColorAnimation { duration: WinTheme.fast } }
        activeFocusOnTab: true
        border.width: activeFocus ? 2 : 0
        border.color: WinTheme.text
        Keys.onReturnPressed: footer.clicked()
        Keys.onSpacePressed: footer.clicked()

        WinText {
            id: label
            anchors.centerIn: parent
            text: footer.text
            color: area.pressed ? WinTheme.textSecondary : WinTheme.text
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: footer.clicked()
        }
    }
}
