/*
 * Windows 11 battery glyph, drawn natively so it can be as wide as the
 * Fluent one (a square SVG icon ends up tiny): rounded outline, cap on the
 * right, fill proportional to the charge, plug on the left while plugged in.
 * Size it with `bodyHeight`; the glyph's width follows.
 */
import QtQuick

Item {
    id: glyph

    property int percent: 0
    property bool charging: false       // show the plug
    property color color: WinTheme.text
    property real bodyHeight: 10

    readonly property real stroke: Math.max(1, Math.round(bodyHeight / 10))
    readonly property real bodyWidth: Math.round(bodyHeight * 1.85)
    readonly property real capWidth: Math.max(1.5, Math.round(bodyHeight * 0.16))
    readonly property real plugSize: Math.round(bodyHeight * 1.35)
    readonly property bool low: percent <= 10 && !charging

    implicitWidth: (charging ? plugSize + 1 : 0) + bodyWidth + capWidth
    implicitHeight: Math.max(bodyHeight, charging ? plugSize : 0)

    FluentIcon {
        id: plug
        visible: glyph.charging
        width: glyph.plugSize
        height: glyph.plugSize
        anchors.verticalCenter: parent.verticalCenter
        glyph: "plug"
        color: glyph.color
    }
    Rectangle {
        id: body
        x: glyph.charging ? glyph.plugSize + 1 : 0
        anchors.verticalCenter: parent.verticalCenter
        width: glyph.bodyWidth
        height: glyph.bodyHeight
        radius: Math.round(glyph.bodyHeight * 0.3)
        color: "transparent"
        border.width: glyph.stroke
        border.color: glyph.color
        antialiasing: true

        Rectangle {   // charge level
            readonly property real inset: glyph.stroke + Math.max(1, Math.round(glyph.bodyHeight * 0.15))
            readonly property real full: parent.width - 2 * inset
            x: inset
            y: inset
            height: parent.height - 2 * inset
            width: glyph.percent <= 0 ? 0 : Math.max(height * 0.6, full * Math.min(100, glyph.percent) / 100)
            radius: Math.max(1, parent.radius - inset)
            color: glyph.low ? WinTheme.critical : glyph.color
            antialiasing: true
            Behavior on width { NumberAnimation { duration: WinTheme.normal } }
        }
    }
    Rectangle {   // cap
        anchors { left: body.right; verticalCenter: body.verticalCenter }
        width: glyph.capWidth
        height: Math.round(glyph.bodyHeight * 0.4)
        radius: width / 2
        color: glyph.color
        antialiasing: true
    }
}
