/*
 * Windows 11 slider: 4 px track (accent part + rest), 20 px thumb with an
 * accent dot that grows on hover and shrinks while dragging.
 * `value` is 0..1; emits moved(value) on user interaction only.
 */
import QtQuick

Item {
    id: slider

    property real value: 0
    property string accessibleName
    readonly property bool pressed: area.pressed
    readonly property bool hovered: area.containsMouse
    signal moved(real value)

    implicitWidth: 200
    implicitHeight: 32
    activeFocusOnTab: true
    Accessible.role: Accessible.Slider
    Accessible.name: accessibleName

    // The value shown: follows `value` except while the user drags.
    property real visualValue: value
    Binding on visualValue {
        value: slider.value
        when: !area.pressed
        restoreMode: Binding.RestoreNone
    }

    readonly property real thumbSize: 20
    readonly property real usable: width - thumbSize

    function setFromX(x) {
        const v = Math.max(0, Math.min(1, (x - thumbSize / 2) / usable))
        visualValue = Math.round(v * 100) / 100
        moved(visualValue)
    }
    function step(delta) {
        visualValue = Math.max(0, Math.min(1, Math.round((visualValue + delta) * 100) / 100))
        moved(visualValue)
    }
    Keys.onLeftPressed: step(-0.01)
    Keys.onRightPressed: step(0.01)
    Keys.onDownPressed: step(-0.01)
    Keys.onUpPressed: step(0.01)
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_PageUp) { step(0.1); event.accepted = true }
        else if (event.key === Qt.Key_PageDown) { step(-0.1); event.accepted = true }
    }

    Rectangle {    // rest of track
        x: slider.thumbSize / 2
        width: slider.usable
        height: 4
        radius: 2
        anchors.verticalCenter: parent.verticalCenter
        color: WinTheme.sliderTrack
    }
    Rectangle {    // filled part
        x: slider.thumbSize / 2
        width: slider.usable * slider.visualValue
        height: 4
        radius: 2
        anchors.verticalCenter: parent.verticalCenter
        color: WinTheme.accent
    }
    Rectangle {    // thumb
        id: thumb
        width: slider.thumbSize
        height: slider.thumbSize
        radius: width / 2
        x: slider.usable * slider.visualValue
        anchors.verticalCenter: parent.verticalCenter
        color: WinTheme.sliderThumb
        border.width: 1
        border.color: slider.activeFocus ? WinTheme.text : WinTheme.sliderThumbStroke

        Rectangle {
            anchors.centerIn: parent
            property real size: slider.pressed ? 10 : (slider.hovered || slider.activeFocus) ? 14 : 12
            width: size
            height: size
            radius: size / 2
            color: slider.pressed ? WinTheme.accentPressed : slider.hovered ? WinTheme.accentHover : WinTheme.accent
            Behavior on size { NumberAnimation { duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        onPressed: (mouse) => { slider.forceActiveFocus(); slider.setFromX(mouse.x) }
        onPositionChanged: (mouse) => { if (pressed) slider.setFromX(mouse.x) }
        onWheel: (wheel) => slider.step(wheel.angleDelta.y > 0 ? 0.02 : -0.02)
    }

    // Value bubble above the thumb while dragging (as Windows shows).
    Rectangle {
        visible: slider.pressed
        width: bubble.implicitWidth + 16
        height: 30
        radius: WinTheme.controlRadius
        color: WinTheme.tooltip
        border.width: 1
        border.color: WinTheme.cardStroke
        x: thumb.x + thumb.width / 2 - width / 2
        y: -height - 2
        WinText {
            id: bubble
            anchors.centerIn: parent
            text: Math.round(slider.visualValue * 100)
            font.pixelSize: WinTheme.caption
        }
    }
}
