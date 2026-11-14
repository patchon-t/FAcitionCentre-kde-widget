/* Windows-style progress ring. */
import QtQuick

FluentIcon {
    id: spinner
    property bool running: true
    glyph: "spinner"
    color: WinTheme.accent
    visible: running
    RotationAnimator on rotation {
        from: 0
        to: 360
        duration: 1000
        loops: Animation.Infinite
        running: spinner.running && spinner.visible
    }
}
