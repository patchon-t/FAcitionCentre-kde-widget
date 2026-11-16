/*
 * Windows 11 indeterminate progress bar: an accent segment sweeping across
 * (shown under sub-page headers while scanning).
 */
import QtQuick

Item {
    id: bar

    property bool running: false

    implicitHeight: 3
    clip: true
    opacity: running ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: WinTheme.normal } }

    Rectangle {
        id: segment
        height: parent.height
        radius: height / 2
        color: WinTheme.accent
        width: bar.width * 0.4
        x: -width
    }
    SequentialAnimation {
        running: bar.running && bar.visible
        loops: Animation.Infinite
        NumberAnimation { target: segment; property: "x"; from: -segment.width; to: bar.width; duration: 1500; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.standard }
        PauseAnimation { duration: 200 }
    }
}
