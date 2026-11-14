/*
 * Description of one toggle tile (data + behaviour, no visuals).
 * main view keeps one of these per tile id; ToggleTile renders it.
 */
import QtQuick

QtObject {
    property string glyph
    property string label
    property string tooltip
    property string moreTooltip
    property bool checked: false
    property bool hasMore: false
    // Backend exists on this system. If false the tile is disabled and
    // `unavailableReason` is shown as its tooltip.
    property bool available: true
    property string unavailableReason
    // Temporarily disabled (e.g. Wi-Fi while airplane mode is on).
    property bool enabled: true
    property string disabledReason

    signal toggled()
    signal moreClicked()
}
