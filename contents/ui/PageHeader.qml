/*
 * Sub-page header, Windows 11 style: back chevron, title, controls on the right.
 */
import QtQuick
import QtQuick.Layouts

Item {
    id: header

    property string title
    default property alias extras: extraRow.data
    signal back()

    implicitHeight: 56

    RowLayout {
        anchors { fill: parent; leftMargin: 12; rightMargin: 20 }
        spacing: 8

        WinIconButton {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            glyph: "chevron-left"
            tooltip: "Back"
            onClicked: header.back()
        }
        WinText {
            Layout.fillWidth: true
            text: header.title
            font.weight: Font.DemiBold
        }
        RowLayout {
            id: extraRow
            spacing: 12
        }
    }
}
