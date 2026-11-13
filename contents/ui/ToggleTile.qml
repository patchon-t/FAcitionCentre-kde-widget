/*
 * Windows 11 style toggle tile: rounded rectangle with an icon, label
 * underneath. Optional split layout: the right part (chevron) emits
 * moreClicked() instead of toggled().
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: tile

    property string iconName
    property string label
    property string tooltip
    property string moreTooltip
    property bool checked: false
    property bool hasMore: false

    signal toggled()
    signal moreClicked()

    readonly property color onColor: Kirigami.Theme.highlightColor
    readonly property color offColor: Qt.alpha(Kirigami.Theme.textColor, 0.07)
    readonly property color hoverTint: checked ? Qt.alpha(Kirigami.Theme.highlightedTextColor, 0.14)
                                               : Qt.alpha(Kirigami.Theme.textColor, 0.07)
    readonly property color pressTint: checked ? Qt.alpha(Kirigami.Theme.highlightedTextColor, 0.24)
                                               : Qt.alpha(Kirigami.Theme.textColor, 0.13)

    implicitWidth: Kirigami.Units.gridUnit * 6
    implicitHeight: bg.height + Kirigami.Units.smallSpacing + caption.implicitHeight
    opacity: enabled ? 1 : 0.4
    Behavior on opacity { NumberAnimation { duration: 150 } }

    activeFocusOnTab: true
    Accessible.role: Accessible.CheckBox
    Accessible.name: label
    Accessible.description: tooltip
    Accessible.checked: checked
    Accessible.onPressAction: tile.toggled()
    Keys.onSpacePressed: tile.toggled()
    Keys.onReturnPressed: tile.toggled()
    Keys.onRightPressed: (event) => {
        if (hasMore) {
            tile.moreClicked()
        } else {
            event.accepted = false
        }
    }

    Rectangle {
        id: bg
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Kirigami.Units.gridUnit * 3
        radius: Kirigami.Units.smallSpacing * 1.5
        color: tile.checked ? tile.onColor : tile.offColor
        border.width: 1
        border.color: tile.activeFocus ? Kirigami.Theme.focusColor
                                       : tile.checked ? Qt.alpha(Kirigami.Theme.highlightedTextColor, 0.15)
                                                      : Qt.alpha(Kirigami.Theme.textColor, 0.12)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 1
            spacing: 0

            // Toggle part
            MouseArea {
                id: mainArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                hoverEnabled: true
                onClicked: tile.toggled()

                Rectangle {
                    anchors.fill: parent
                    radius: bg.radius - 1
                    color: mainArea.pressed ? tile.pressTint : mainArea.containsMouse ? tile.hoverTint : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.smallMedium
                    height: width
                    source: tile.iconName
                    selected: tile.checked
                }
            }

            Rectangle {
                visible: tile.hasMore
                Layout.fillHeight: true
                Layout.topMargin: Kirigami.Units.smallSpacing * 2
                Layout.bottomMargin: Kirigami.Units.smallSpacing * 2
                implicitWidth: 1
                color: tile.checked ? Qt.alpha(Kirigami.Theme.highlightedTextColor, 0.35)
                                    : Qt.alpha(Kirigami.Theme.textColor, 0.2)
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            // "More" part
            MouseArea {
                id: moreArea
                visible: tile.hasMore
                Layout.fillHeight: true
                implicitWidth: Math.round(Kirigami.Units.gridUnit * 2.25)
                hoverEnabled: true
                onClicked: tile.moreClicked()

                Rectangle {
                    anchors.fill: parent
                    radius: bg.radius - 1
                    color: moreArea.pressed ? tile.pressTint : moreArea.containsMouse ? tile.hoverTint : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.small
                    height: width
                    source: "go-next-symbolic"
                    selected: tile.checked
                }
            }
        }
    }

    PlasmaComponents3.Label {
        id: caption
        anchors { top: bg.bottom; topMargin: Kirigami.Units.smallSpacing; left: parent.left; right: parent.right }
        text: tile.label
        font: Kirigami.Theme.smallFont
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        maximumLineCount: 1
        textFormat: Text.PlainText
    }

    PlasmaComponents3.ToolTip {
        text: moreArea.containsMouse && tile.moreTooltip !== "" ? tile.moreTooltip : tile.tooltip
        visible: (mainArea.containsMouse || moreArea.containsMouse) && text !== ""
        delay: Kirigami.Units.toolTipDelay
    }
}
