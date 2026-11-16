/*
 * Windows 11 flyout list item: glyph, title + subtitle, optional expanded
 * area (buttons, password box) shown when `expanded`.
 * `selected` draws the accent pill on the left (audio output list).
 */
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: item

    property string glyph
    property string badgeGlyph           // small glyph next to the main one (e.g. lock)
    property string title
    property string subtitle
    property bool expanded: false
    property bool selected: false
    property bool busy: false
    property string tooltip
    property string trailingText          // e.g. Bluetooth battery "69%"
    property string trailingGlyph
    property bool showInfo: false         // (i) button on the expanded item
    signal infoClicked()
    default property alias expandedContent: extra.data

    signal clicked()

    implicitHeight: head.height + (expanded ? extra.implicitHeight + 12 : 0)
    Behavior on implicitHeight { NumberAnimation { duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
    clip: true
    radius: WinTheme.controlRadius
    color: expanded ? WinTheme.layer
         : area.pressed ? WinTheme.subtlePressed
         : (area.containsMouse || selected) ? WinTheme.subtleHover : "transparent"
    border.width: expanded ? 1 : 0
    border.color: WinTheme.controlStroke
    Behavior on color { ColorAnimation { duration: WinTheme.fast } }

    activeFocusOnTab: true
    Accessible.role: Accessible.ListItem
    Accessible.name: title
    Keys.onReturnPressed: item.clicked()
    Keys.onSpacePressed: item.clicked()

    Rectangle {   // selection / expanded pill
        visible: item.selected || item.expanded
        x: 0
        width: 3
        height: item.expanded ? Math.max(16, item.height - 24) : 16
        radius: 1.5
        y: item.expanded ? 12 : (head.height - height) / 2
        color: WinTheme.accent
        Behavior on height { NumberAnimation { duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
    }

    Item {
        id: head
        width: parent.width
        height: 52

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            onClicked: item.clicked()
        }

        FluentIcon {
            id: icon
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            glyph: item.glyph
        }
        FluentIcon {
            visible: item.badgeGlyph !== ""
            anchors { left: icon.right; leftMargin: -6; bottom: icon.bottom; bottomMargin: -3 }
            width: 10
            height: 10
            glyph: item.badgeGlyph
        }
        Column {
            anchors { left: icon.right; leftMargin: 16; right: trailing.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
            WinText {
                width: parent.width
                text: item.title
            }
            WinText {
                width: parent.width
                visible: text !== ""
                text: item.subtitle
                font.pixelSize: WinTheme.caption
                color: WinTheme.textSecondary
            }
        }
        Row {
            id: trailing
            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
            spacing: 6
            WinText {
                visible: item.trailingText !== ""
                anchors.verticalCenter: parent.verticalCenter
                text: item.trailingText
                font.pixelSize: WinTheme.caption
                color: WinTheme.textSecondary
            }
            FluentIcon {
                visible: item.trailingGlyph !== ""
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                glyph: item.trailingGlyph
                color: WinTheme.textSecondary
            }
            Spinner {
                anchors.verticalCenter: parent.verticalCenter
                running: item.busy
                width: running ? 16 : 0
            }
            WinIconButton {
                visible: item.showInfo && item.expanded
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                glyph: "info"
                tooltip: "Properties"
                onClicked: item.infoClicked()
            }
        }
        WinToolTip {
            text: item.tooltip
            shown: area.containsMouse && !item.expanded
        }
    }

    ColumnLayout {
        id: extra
        anchors { top: head.bottom; left: parent.left; right: parent.right; leftMargin: 52; rightMargin: 16 }
        spacing: 8
        visible: item.expanded
    }
}
