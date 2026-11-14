/* Thin Windows-style scroll indicator for a Flickable; visible while scrolling or hovered. */
import QtQuick

Rectangle {
    id: bar

    required property Flickable flickable
    property bool hovered: false

    readonly property bool needed: flickable.visibleArea.heightRatio < 1
    visible: needed
    anchors { right: parent.right; rightMargin: 2; top: parent.top; bottom: parent.bottom }
    width: 6
    color: "transparent"
    opacity: (flickable.moving || hovered) ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: WinTheme.slow } }

    Rectangle {
        x: (parent.width - width) / 2
        width: bar.hovered ? 6 : 2
        radius: width / 2
        y: bar.flickable.visibleArea.yPosition * bar.height
        height: bar.flickable.visibleArea.heightRatio * bar.height
        color: WinTheme.textTertiary
        Behavior on width { NumberAnimation { duration: WinTheme.fast } }
    }
}
