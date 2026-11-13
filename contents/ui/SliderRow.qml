/*
 * Icon + slider (+ optional ">" button). `value` is the backend value
 * (0..1); while the user drags, the backend value is ignored so the handle
 * doesn't fight the pointer.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

RowLayout {
    id: row

    property string iconName
    property real value: 0
    property bool iconClickable: false
    property string iconTooltip
    property string sliderTooltip
    property bool hasMore: false
    property string moreTooltip

    signal moved(real value)
    signal iconClicked()
    signal moreClicked()

    spacing: Kirigami.Units.smallSpacing

    PlasmaComponents3.ToolButton {
        id: iconButton
        icon.name: row.iconName
        // Not clickable: keep it looking like a plain icon.
        flat: true
        hoverEnabled: row.iconClickable
        down: row.iconClickable && pressed
        activeFocusOnTab: row.iconClickable
        onClicked: {
            if (row.iconClickable) {
                row.iconClicked()
            }
        }
        Accessible.name: row.iconTooltip
        PlasmaComponents3.ToolTip {
            text: row.iconTooltip
            visible: iconHover.hovered && text !== ""
            delay: Kirigami.Units.toolTipDelay
        }
        HoverHandler { id: iconHover }
    }

    PlasmaComponents3.Slider {
        id: slider
        Layout.fillWidth: true
        from: 0
        to: 1
        stepSize: 0.01
        onMoved: row.moved(value)
        Accessible.name: row.sliderTooltip

        Binding {
            target: slider
            property: "value"
            value: row.value
            when: !slider.pressed
            restoreMode: Binding.RestoreNone
        }
        PlasmaComponents3.ToolTip {
            text: row.sliderTooltip + ": " + Math.round(slider.value * 100) + "%"
            visible: (slider.hovered || slider.pressed) && row.sliderTooltip !== ""
            delay: slider.pressed ? 0 : Kirigami.Units.toolTipDelay
        }
    }

    PlasmaComponents3.ToolButton {
        id: moreButton
        visible: row.hasMore
        icon.name: "go-next-symbolic"
        onClicked: row.moreClicked()
        Accessible.name: row.moreTooltip
        PlasmaComponents3.ToolTip {
            text: row.moreTooltip
            visible: moreButton.hovered && text !== ""
            delay: Kirigami.Units.toolTipDelay
        }
    }
    // Keeps both sliders the same length when only one row has a ">" button.
    Item {
        visible: !row.hasMore
        implicitWidth: iconButton.implicitWidth
        implicitHeight: 1
    }
}
