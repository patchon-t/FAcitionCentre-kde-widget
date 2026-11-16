/*
 * Windows 11 24H2 tile pager: dots (current one larger) with an up arrow
 * above and a down arrow below when there is a page that way.
 */
import QtQuick

Column {
    id: pager

    property int pages: 1
    property int current: 0
    signal pageRequested(int page)

    visible: pages > 1
    spacing: 6
    width: 12

    component Arrow: Item {
        id: arrow
        property bool up: true
        property bool shown: true
        width: 12
        height: 10
        opacity: shown ? 1 : 0
        Canvas {
            id: canvas
            anchors.centerIn: parent
            width: 8
            height: 6
            property color fill: area.containsMouse ? WinTheme.text : WinTheme.textSecondary
            onFillChanged: requestPaint()
            onPaint: {
                const g = getContext("2d")
                g.reset()
                g.fillStyle = fill
                g.beginPath()
                if (arrow.up) { g.moveTo(0, 6); g.lineTo(4, 0); g.lineTo(8, 6) }
                else { g.moveTo(0, 0); g.lineTo(4, 6); g.lineTo(8, 0) }
                g.closePath()
                g.fill()
            }
        }
        MouseArea {
            id: area
            anchors.fill: parent
            anchors.margins: -4
            enabled: arrow.shown
            hoverEnabled: true
            onClicked: pager.pageRequested(pager.current + (arrow.up ? -1 : 1))
        }
    }

    Arrow { up: true; shown: pager.current > 0 }
    Repeater {
        model: pager.pages
        Item {
            required property int index
            width: 12
            height: 8
            Rectangle {
                anchors.centerIn: parent
                readonly property bool active: index === pager.current
                width: active ? 7 : 4
                height: width
                radius: width / 2
                color: active ? WinTheme.textSecondary : WinTheme.textTertiary
                Behavior on width { NumberAnimation { duration: WinTheme.normal } }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: pager.pageRequested(index)
            }
        }
    }
    Arrow { up: false; shown: pager.current < pager.pages - 1 }
}
