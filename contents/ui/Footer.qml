/*
 * Footer strip: battery on the left, edit + settings on the right.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Rectangle {
    id: footer

    property bool hasBattery: false
    property string batteryIcon
    property string batteryText
    property bool editMode: false

    signal editClicked()
    signal settingsClicked()

    implicitHeight: layout.implicitHeight + Kirigami.Units.smallSpacing * 2
    radius: Kirigami.Units.smallSpacing * 1.5
    // Slightly darker than the popup, derived from the theme.
    color: Qt.darker(Kirigami.Theme.backgroundColor, 1.12)
    border.width: 1
    border.color: Qt.alpha(Kirigami.Theme.textColor, 0.08)

    RowLayout {
        id: layout
        anchors {
            fill: parent
            leftMargin: Kirigami.Units.largeSpacing
            rightMargin: Kirigami.Units.smallSpacing
            topMargin: Kirigami.Units.smallSpacing
            bottomMargin: Kirigami.Units.smallSpacing
        }
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            visible: footer.hasBattery
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: Kirigami.Units.iconSizes.smallMedium
            source: footer.batteryIcon
            fallback: "battery"
        }
        PlasmaComponents3.Label {
            visible: footer.hasBattery
            text: footer.batteryText
            textFormat: Text.PlainText
            HoverHandler { id: batteryHover }
            PlasmaComponents3.ToolTip {
                text: "Battery at " + footer.batteryText
                visible: batteryHover.hovered
                delay: Kirigami.Units.toolTipDelay
            }
        }

        Item { Layout.fillWidth: true }

        PlasmaComponents3.ToolButton {
            id: editButton
            icon.name: footer.editMode ? "dialog-ok-apply-symbolic" : "document-edit-symbolic"
            text: footer.editMode ? "Done" : ""
            display: footer.editMode ? PlasmaComponents3.AbstractButton.TextBesideIcon : PlasmaComponents3.AbstractButton.IconOnly
            onClicked: footer.editClicked()
            Accessible.name: footer.editMode ? "Finish editing" : "Edit quick settings"
            PlasmaComponents3.ToolTip {
                text: editButton.Accessible.name
                visible: editButton.hovered
                delay: Kirigami.Units.toolTipDelay
            }
        }
        PlasmaComponents3.ToolButton {
            id: settingsButton
            icon.name: "configure-symbolic"
            onClicked: footer.settingsClicked()
            Accessible.name: "Open System Settings"
            PlasmaComponents3.ToolTip {
                text: settingsButton.Accessible.name
                visible: settingsButton.hovered
                delay: Kirigami.Units.toolTipDelay
            }
        }
    }
}
