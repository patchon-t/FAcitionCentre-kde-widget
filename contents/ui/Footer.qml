/*
 * Main page footer (content only; the card draws the darker strip):
 * battery on the left; edit + settings, or Add + Done in edit mode.
 */
import QtQuick
import QtQuick.Layouts

Item {
    id: footer

    property bool hasBattery: false
    property string batteryGlyph
    property int batteryPercent: 0
    property string batteryText
    property bool editMode: false
    property bool canAdd: false

    signal editClicked()
    signal doneClicked()
    signal addClicked(Item anchor)
    signal settingsClicked()

    implicitHeight: WinTheme.footerHeight

    // Battery
    Rectangle {
        id: battery
        visible: footer.hasBattery
        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
        width: batteryRow.implicitWidth + 16
        height: 32
        radius: WinTheme.controlRadius
        color: batteryArea.pressed ? WinTheme.subtlePressed : batteryArea.containsMouse ? WinTheme.subtleHover : "transparent"
        Behavior on color { ColorAnimation { duration: WinTheme.fast } }
        Row {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 8
            FluentIcon {
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                glyph: footer.batteryGlyph
            }
            WinText {
                anchors.verticalCenter: parent.verticalCenter
                text: footer.batteryPercent + "%"
                font.pixelSize: WinTheme.caption
            }
        }
        MouseArea {
            id: batteryArea
            anchors.fill: parent
            hoverEnabled: true
        }
        WinToolTip {
            text: "Battery: " + footer.batteryText
            shown: batteryArea.containsMouse
        }
    }

    // Normal: edit + settings
    Row {
        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
        spacing: 4
        visible: opacity > 0
        opacity: footer.editMode ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: WinTheme.fast } }

        WinIconButton {
            width: 32
            height: 32
            glyph: "pencil"
            tooltip: "Edit quick settings"
            onClicked: footer.editClicked()
        }
        WinIconButton {
            width: 32
            height: 32
            glyph: "gear"
            tooltip: "All settings"
            onClicked: footer.settingsClicked()
        }
    }

    // Edit mode: Add + Done
    Row {
        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
        spacing: 8
        visible: opacity > 0
        opacity: footer.editMode ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: WinTheme.fast } }

        WinButton {
            id: addButton
            text: "Add"
            glyph: "plus"
            implicitWidth: 80
            enabled: footer.canAdd
            onClicked: footer.addClicked(addButton)
        }
        WinButton {
            text: "Done"
            accent: true
            implicitWidth: 80
            onClicked: footer.doneClicked()
        }
    }
}
