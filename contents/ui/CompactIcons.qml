/*
 * Panel button: network, volume and battery icons side by side (stacked
 * in a vertical panel), with one shared hover highlight, like the
 * Windows 11 taskbar. Scrolling over it changes the volume.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

MouseArea {
    id: compact

    required property QtObject backend
    property bool vertical: false
    property bool expanded: false

    signal expandRequested(bool expand)

    readonly property bool showNetwork: backend.networkIconAvailable
    readonly property bool showVolume: backend.volumeAvailable
    readonly property bool showBattery: backend.hasBattery

    readonly property int thickness: vertical ? width : height
    // Windows taskbar: 16 px glyphs, scaled up a little on thick panels.
    readonly property int iconSize: Math.max(16, Math.min(24, Math.round(thickness * 0.36)))
    readonly property int padding: 8

    Layout.minimumWidth: vertical ? 0 : grid.implicitWidth + padding * 2
    Layout.preferredWidth: Layout.minimumWidth
    Layout.maximumWidth: vertical ? Infinity : Layout.minimumWidth
    Layout.minimumHeight: vertical ? grid.implicitHeight + padding * 2 : 0
    Layout.preferredHeight: Layout.minimumHeight
    Layout.maximumHeight: vertical ? Layout.minimumHeight : Infinity

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    property bool wasExpanded: false
    onPressed: wasExpanded = expanded
    onClicked: expandRequested(!wasExpanded)

    property int wheelDelta: 0
    onWheel: (wheel) => {
        if (!backend.volumeAvailable) {
            return
        }
        wheelDelta += wheel.angleDelta.y
        let steps = 0
        while (Math.abs(wheelDelta) >= 120) {
            steps += wheelDelta > 0 ? 1 : -1
            wheelDelta += wheelDelta > 0 ? -120 : 120
        }
        if (steps !== 0) {
            backend.setVolume(Math.max(0, Math.min(1, backend.volume + steps * 0.05)))
        }
    }

    Accessible.role: Accessible.Button
    Accessible.name: "Quick Settings"

    // Shared hover / open highlight behind all icons.
    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: 4
        color: Kirigami.Theme.textColor
        opacity: compact.pressed ? 0.05 : compact.expanded ? 0.09 : compact.containsMouse ? 0.07 : 0
        Behavior on opacity { NumberAnimation { duration: WinTheme.fast } }
    }

    GridLayout {
        id: grid
        anchors.centerIn: parent
        flow: compact.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rows: compact.vertical ? -1 : 1
        columns: compact.vertical ? 1 : -1
        rowSpacing: 10
        columnSpacing: 10

        FluentIcon {
            visible: compact.showNetwork
            Layout.preferredWidth: compact.iconSize
            Layout.preferredHeight: compact.iconSize
            glyph: compact.backend.networkGlyph
            color: Kirigami.Theme.textColor
        }
        FluentIcon {
            visible: compact.showVolume
            Layout.preferredWidth: compact.iconSize
            Layout.preferredHeight: compact.iconSize
            glyph: compact.backend.volumeGlyph
            color: Kirigami.Theme.textColor
        }
        FluentIcon {
            visible: compact.showBattery
            Layout.preferredWidth: compact.iconSize + 4
            Layout.preferredHeight: compact.iconSize + 4
            glyph: compact.backend.batteryGlyph
            color: Kirigami.Theme.textColor
        }
        // Never leave an invisible, unclickable widget in the panel.
        FluentIcon {
            visible: !compact.showNetwork && !compact.showVolume && !compact.showBattery
            Layout.preferredWidth: compact.iconSize
            Layout.preferredHeight: compact.iconSize
            glyph: "gear"
            color: Kirigami.Theme.textColor
        }
    }
}
