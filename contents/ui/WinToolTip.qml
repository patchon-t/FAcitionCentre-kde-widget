/*
 * Windows 11 tooltip. Attach inside any item: WinToolTip { text: "..."; shown: hover.hovered }
 * Shown below its parent (Windows places tooltips under the pointer) so it
 * stays inside the flyout window.
 */
import QtQuick
import QtQuick.Controls as QQC2

QQC2.ToolTip {
    id: tip

    property bool shown: false

    visible: shown && text !== ""
    delay: 600
    timeout: -1
    y: parent ? parent.height + 6 : 0
    x: parent ? Math.round((parent.width - width) / 2) : 0
    padding: 0
    margins: 4

    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: WinTheme.normal } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: WinTheme.fast } }

    contentItem: WinText {
        leftPadding: 8
        rightPadding: 8
        topPadding: 6
        bottomPadding: 8
        text: tip.text
        font.pixelSize: WinTheme.caption
        maximumLineCount: 3
        wrapMode: Text.Wrap
        elide: Text.ElideNone
    }
    background: Rectangle {
        implicitWidth: 40
        implicitHeight: 28
        radius: WinTheme.controlRadius
        color: WinTheme.tooltip
        border.width: 1
        border.color: WinTheme.cardStroke
    }
}
