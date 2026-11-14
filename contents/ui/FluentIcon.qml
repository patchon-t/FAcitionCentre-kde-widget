/*
 * One of the bundled Fluent-style line icons (contents/icons/<glyph>.svg),
 * recoloured to `color`.
 */
import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.Icon {
    property string glyph

    implicitWidth: WinTheme.iconSize
    implicitHeight: WinTheme.iconSize
    source: glyph !== "" ? Qt.resolvedUrl("../icons/" + glyph + ".svg") : ""
    isMask: true
    color: WinTheme.text
    smooth: true
}
