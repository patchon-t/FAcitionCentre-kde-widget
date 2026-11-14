pragma Singleton
/*
 * Windows 11 design tokens (WinUI 3 / Fluent): colours for dark and light
 * mode, metrics and motion curves. main.qml feeds in the Plasma colour
 * scheme so "auto" mode follows light/dark.
 */
import QtQuick

QtObject {
    id: theme

    // ---- inputs (set from main.qml) -----------------------------------------
    property int mode: 0                      // 0 = follow Plasma, 1 = dark, 2 = light
    property bool useSystemAccent: false
    property color systemBackground: "#202020"
    property color systemAccent: "#3daee9"

    function luminance(c) { return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b }
    readonly property bool dark: mode === 1 || (mode === 0 && luminance(systemBackground) < 0.5)

    function a(c, alpha) { return Qt.rgba(c.r, c.g, c.b, alpha) }
    readonly property color white: "#ffffff"
    readonly property color black: "#000000"

    // ---- accent --------------------------------------------------------------
    readonly property color accent: useSystemAccent
        ? (dark ? Qt.tint(systemAccent, Qt.rgba(1, 1, 1, 0.35)) : Qt.darker(systemAccent, 1.15))
        : (dark ? "#4cc2ff" : "#005fb8")
    readonly property color accentHover: a(accent, 0.9)
    readonly property color accentPressed: a(accent, 0.8)
    readonly property color textOnAccent: luminance(accent) > 0.55 ? black : white

    // ---- surfaces ------------------------------------------------------------
    readonly property color flyout: dark ? "#2c2c2c" : "#f9f9f9"
    readonly property color footer: dark ? "#202020" : "#eeeeee"
    readonly property color cardStroke: dark ? a(white, 0.08) : a(black, 0.07)
    readonly property color shadow: black
    readonly property color layer: dark ? a(white, 0.05) : a(white, 0.7)       // expanded list item

    // ---- text ----------------------------------------------------------------
    readonly property color text: dark ? white : a(black, 0.896)
    readonly property color textSecondary: dark ? a(white, 0.786) : a(black, 0.606)
    readonly property color textTertiary: dark ? a(white, 0.544) : a(black, 0.446)
    readonly property color textDisabled: dark ? a(white, 0.363) : a(black, 0.361)
    readonly property color critical: dark ? "#ff99a4" : "#c42b1c"

    // ---- controls ------------------------------------------------------------
    readonly property color control: dark ? a(white, 0.0605) : a(white, 0.7)
    readonly property color controlHover: dark ? a(white, 0.0837) : a("#f9f9f9", 0.5)
    readonly property color controlPressed: dark ? a(white, 0.0326) : a("#f9f9f9", 0.3)
    readonly property color controlDisabled: dark ? a(white, 0.0419) : a("#f9f9f9", 0.3)
    readonly property color controlStroke: dark ? a(white, 0.0698) : a(black, 0.0578)
    readonly property color controlStrokeBottom: dark ? a(white, 0.0465) : a(black, 0.1622)
    readonly property color subtleHover: dark ? a(white, 0.0605) : a(black, 0.0373)
    readonly property color subtlePressed: dark ? a(white, 0.0419) : a(black, 0.0241)
    readonly property color divider: dark ? a(white, 0.0837) : a(black, 0.0803)

    readonly property color sliderTrack: dark ? a(white, 0.544) : a(black, 0.446)
    readonly property color sliderThumb: dark ? "#454545" : white
    readonly property color sliderThumbStroke: dark ? a(white, 0.094) : a(black, 0.0578)

    readonly property color toggleOffStroke: dark ? a(white, 0.6) : a(black, 0.606)
    readonly property color toggleOffKnob: dark ? a(white, 0.786) : a(black, 0.606)

    readonly property color tooltip: dark ? "#2c2c2c" : "#f9f9f9"

    // ---- metrics (logical px, from the Windows 11 flyout) --------------------
    readonly property int flyoutWidth: 360
    readonly property int flyoutGap: 12        // space to taskbar / screen edge
    readonly property int cardRadius: 8
    readonly property int controlRadius: 4
    readonly property int padding: 24
    readonly property int tileWidth: 96
    readonly property int tileHeight: 48
    readonly property int tileGap: 12
    readonly property int tileRowHeight: 96    // tile + label
    readonly property int footerHeight: 48
    readonly property int iconSize: 16

    // ---- typography ------------------------------------------------------------
    readonly property string fontFamily: {
        const wanted = ["Segoe UI Variable Text", "Segoe UI Variable", "Segoe UI", "Inter", "Noto Sans"]
        const have = Qt.fontFamilies()
        for (const f of wanted) {
            if (have.indexOf(f) >= 0) {
                return f
            }
        }
        return Qt.application.font.family
    }
    readonly property int caption: 12
    readonly property int body: 14

    // ---- motion -------------------------------------------------------------
    readonly property int fast: 83
    readonly property int normal: 167
    readonly property int slow: 250
    // Fluent "decelerate" / "accelerate" / "standard" cubic-beziers, as Qt BezierSpline lists.
    readonly property var decelerate: [0.1, 0.9, 0.2, 1.0, 1, 1]
    readonly property var accelerate: [0.7, 0.0, 1.0, 0.5, 1, 1]
    readonly property var standard: [0.8, 0.0, 0.2, 1.0, 1, 1]
}
