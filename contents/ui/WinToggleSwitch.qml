/*
 * Windows 11 toggle switch (40 x 20). The knob grows on hover and
 * stretches while pressed, like WinUI.
 */
import QtQuick

Item {
    id: toggle

    property bool checked: false
    property string accessibleName
    signal toggled()

    implicitWidth: 40
    implicitHeight: 20
    opacity: enabled ? 1 : 0.45
    activeFocusOnTab: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: accessibleName
    Accessible.checked: checked
    Accessible.onToggleAction: toggle.toggled()
    Keys.onSpacePressed: toggle.toggled()

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: toggle.checked ? (area.pressed ? WinTheme.accentPressed : area.containsMouse ? WinTheme.accentHover : WinTheme.accent)
                              : (area.containsMouse ? WinTheme.controlHover : WinTheme.control)
        border.width: toggle.checked ? 0 : 1
        border.color: toggle.activeFocus ? WinTheme.text : WinTheme.toggleOffStroke
        Behavior on color { ColorAnimation { duration: WinTheme.fast } }
    }
    Rectangle {
        id: knob
        readonly property real size: area.pressed ? 14 : area.containsMouse ? 14 : 12
        width: area.pressed ? 17 : size
        height: size
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter
        x: toggle.checked ? toggle.width - width - 4 : 4
        color: toggle.checked ? WinTheme.textOnAccent : WinTheme.toggleOffKnob
        Behavior on x { NumberAnimation { duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.standard } }
        Behavior on width { NumberAnimation { duration: WinTheme.fast } }
        Behavior on height { NumberAnimation { duration: WinTheme.fast } }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        onClicked: toggle.toggled()
    }
}
