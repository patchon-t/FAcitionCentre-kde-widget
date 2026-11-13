/*
 * Header of a sub-page: back arrow, title, optional controls on the right.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

RowLayout {
    id: header

    property string title
    default property alias extras: extraRow.data

    signal back()

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents3.ToolButton {
        id: backButton
        icon.name: "go-previous-symbolic"
        onClicked: header.back()
        Accessible.name: "Back"
        PlasmaComponents3.ToolTip {
            text: "Back"
            visible: backButton.hovered
            delay: Kirigami.Units.toolTipDelay
        }
    }
    Kirigami.Heading {
        Layout.fillWidth: true
        level: 4
        text: header.title
        elide: Text.ElideRight
    }
    RowLayout {
        id: extraRow
        spacing: Kirigami.Units.smallSpacing
    }
}
