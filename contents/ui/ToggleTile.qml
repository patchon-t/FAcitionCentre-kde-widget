/*
 * Windows 11 quick-settings tile: 96 x 48 button, caption underneath.
 * Optional split layout: the right half (chevron) opens a sub-page.
 * In edit mode an unpin badge sits on the top-right corner.
 */
import QtQuick

Item {
    id: tile

    property string glyph
    property string label
    property string tooltip
    property string moreTooltip
    property bool checked: false
    property bool hasMore: false
    property bool editMode: false

    signal toggled()
    signal moreClicked()
    signal unpinClicked()

    implicitWidth: WinTheme.tileWidth
    implicitHeight: WinTheme.tileRowHeight

    readonly property bool on: checked && enabled
    readonly property color fg: !enabled ? WinTheme.textDisabled : on ? WinTheme.textOnAccent : WinTheme.text

    function fill(area) {
        if (!enabled) {
            return WinTheme.controlDisabled
        }
        if (on) {
            return area.pressed ? WinTheme.accentPressed : area.containsMouse ? WinTheme.accentHover : WinTheme.accent
        }
        return area.pressed ? WinTheme.controlPressed : area.containsMouse ? WinTheme.controlHover : WinTheme.control
    }

    activeFocusOnTab: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.description: tooltip
    Accessible.checked: checked
    Accessible.onPressAction: tile.toggled()
    Keys.onSpacePressed: tile.toggled()
    Keys.onReturnPressed: tile.toggled()
    Keys.onRightPressed: (event) => { if (hasMore) tile.moreClicked(); else event.accepted = false }

    Rectangle {
        id: button
        width: WinTheme.tileWidth
        height: WinTheme.tileHeight
        radius: WinTheme.controlRadius
        // The whole tile's base colour; each half paints its own hover state on top.
        color: tile.enabled ? (tile.on ? WinTheme.accent : WinTheme.control) : WinTheme.controlDisabled
        border.width: tile.on ? 0 : 1
        border.color: WinTheme.controlStroke
        Behavior on color { ColorAnimation { duration: WinTheme.normal } }

        // Light-mode bottom edge, like WinUI control elevation borders.
        Rectangle {
            visible: !WinTheme.dark && !tile.on
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: WinTheme.controlRadius; rightMargin: WinTheme.controlRadius }
            height: 1
            color: WinTheme.controlStrokeBottom
        }

        Rectangle {   // focus ring
            visible: tile.activeFocus
            anchors.fill: parent
            anchors.margins: -3
            radius: WinTheme.controlRadius + 3
            color: "transparent"
            border.width: 2
            border.color: WinTheme.text
        }

        // Toggle half (or whole tile)
        MouseArea {
            id: mainArea
            x: 0
            width: tile.hasMore ? parent.width / 2 : parent.width
            height: parent.height
            hoverEnabled: true
            enabled: !tile.editMode
            onClicked: tile.toggled()

            Rectangle {
                anchors.fill: parent
                anchors.margins: tile.on ? 0 : 1
                radius: WinTheme.controlRadius
                // Square the inner edge of a split tile.
                Rectangle {
                    visible: tile.hasMore
                    anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                    width: WinTheme.controlRadius
                    color: parent.color
                }
                color: tile.enabled && (mainArea.containsMouse || mainArea.pressed) ? tile.fill(mainArea) : "transparent"
                Behavior on color { ColorAnimation { duration: WinTheme.fast } }
            }
            FluentIcon {
                anchors.centerIn: parent
                glyph: tile.glyph
                color: mainArea.pressed && !tile.on ? WinTheme.textSecondary : tile.fg
                scale: mainArea.pressed ? 0.9 : 1
                Behavior on scale { NumberAnimation { duration: WinTheme.fast } }
                Behavior on color { ColorAnimation { duration: WinTheme.normal } }
            }
        }

        Rectangle {   // split divider
            visible: tile.hasMore
            x: parent.width / 2
            y: 0
            width: 1
            height: parent.height
            color: tile.on ? WinTheme.a(WinTheme.textOnAccent, 0.15) : WinTheme.controlStroke
        }

        // Chevron half
        MouseArea {
            id: moreArea
            visible: tile.hasMore
            x: parent.width / 2 + 1
            width: parent.width / 2 - 1
            height: parent.height
            hoverEnabled: true
            enabled: !tile.editMode
            onClicked: tile.moreClicked()

            Rectangle {
                anchors.fill: parent
                anchors.margins: tile.on ? 0 : 1
                anchors.leftMargin: 0
                radius: WinTheme.controlRadius
                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: WinTheme.controlRadius
                    color: parent.color
                }
                color: tile.enabled && (moreArea.containsMouse || moreArea.pressed) ? tile.fill(moreArea) : "transparent"
                Behavior on color { ColorAnimation { duration: WinTheme.fast } }
            }
            FluentIcon {
                anchors.centerIn: parent
                width: 12
                height: 12
                glyph: "chevron-right"
                color: tile.fg
            }
        }
    }

    WinText {
        anchors { top: button.bottom; topMargin: 8; horizontalCenter: button.horizontalCenter }
        width: WinTheme.tileWidth + WinTheme.tileGap - 4
        horizontalAlignment: Text.AlignHCenter
        text: tile.label
        font.pixelSize: WinTheme.caption
        color: tile.enabled ? WinTheme.text : WinTheme.textDisabled
    }

    // Edit mode: unpin badge
    Rectangle {
        id: badge
        visible: tile.editMode
        width: 24
        height: 24
        radius: 12
        x: button.width - width / 2 - 2
        y: -width / 2 + 2
        z: 2
        color: badgeArea.pressed ? WinTheme.footer : badgeArea.containsMouse ? Qt.lighter(WinTheme.flyout, WinTheme.dark ? 1.25 : 0.97) : WinTheme.flyout
        border.width: 1
        border.color: WinTheme.cardStroke
        scale: tile.editMode ? 1 : 0
        Behavior on scale { NumberAnimation { duration: WinTheme.normal; easing.type: Easing.BezierSpline; easing.bezierCurve: WinTheme.decelerate } }
        FluentIcon {
            anchors.centerIn: parent
            width: 12
            height: 12
            glyph: "unpin"
        }
        MouseArea {
            id: badgeArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: tile.unpinClicked()
        }
        WinToolTip {
            text: "Unpin"
            shown: badgeArea.containsMouse
        }
    }

    WinToolTip {
        text: moreArea.containsMouse && tile.moreTooltip !== "" ? tile.moreTooltip : tile.tooltip
        shown: !tile.editMode && (mainArea.containsMouse || moreArea.containsMouse)
    }
}
