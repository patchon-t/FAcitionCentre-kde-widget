/*
 * Sub-page header, Windows 11 24H2 style: back arrow, title, controls on
 * the right, and an indeterminate progress bar underneath while busy.
 */
import QtQuick
import QtQuick.Layouts

Item {
    id: header

    property string title
    property bool busy: false
    default property alias extras: extraRow.data
    signal back()

    implicitHeight: 52

    RowLayout {
        anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 12; rightMargin: 20 }
        height: 48
        spacing: 8

        WinIconButton {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            glyph: "arrow-left"
            tooltip: "Back"
            onClicked: header.back()
        }
        WinText {
            Layout.fillWidth: true
            text: header.title
        }
        RowLayout {
            id: extraRow
            spacing: 12
        }
    }
    WinProgressBar {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: 1 }
        running: header.busy
    }
}
