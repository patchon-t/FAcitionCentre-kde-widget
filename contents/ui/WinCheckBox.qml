/*
 * Windows 11 check box: 20 px rounded square, accent fill with a check mark when checked.
 */
import QtQuick

Item {
    id: box

    property bool checked: false
    property string text
    signal toggled()

    implicitWidth: row.implicitWidth
    implicitHeight: 32
    activeFocusOnTab: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: text
    Accessible.checked: checked
    Keys.onSpacePressed: box.toggled()

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        Rectangle {
            width: 20
            height: 20
            radius: WinTheme.controlRadius
            anchors.verticalCenter: parent.verticalCenter
            color: box.checked ? (area.pressed ? WinTheme.accentPressed : area.containsMouse ? WinTheme.accentHover : WinTheme.accent)
                               : (area.containsMouse ? WinTheme.controlHover : WinTheme.control)
            border.width: box.checked ? 0 : 1
            border.color: box.activeFocus ? WinTheme.text : WinTheme.toggleOffStroke
            Behavior on color { ColorAnimation { duration: WinTheme.fast } }
            FluentIcon {
                anchors.centerIn: parent
                width: 14
                height: 14
                glyph: "check"
                color: WinTheme.textOnAccent
                scale: box.checked ? 1 : 0
                Behavior on scale { NumberAnimation { duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
            }
        }
        WinText {
            anchors.verticalCenter: parent.verticalCenter
            text: box.text
        }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: box.toggled()
    }
}
