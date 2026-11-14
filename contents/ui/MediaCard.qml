/*
 * Windows 11 media card above the quick settings: app, title, artist,
 * album art, previous / play-pause / next.
 */
import QtQuick
import org.kde.kirigami as Kirigami

WinCard {
    id: card

    // MprisSource (or null when the MPRIS plugin is unavailable)
    property var media: null
    readonly property bool active: media !== null && media.hasPlayer

    implicitWidth: WinTheme.flyoutWidth
    implicitHeight: 176

    Row {
        id: appRow
        x: WinTheme.padding
        y: 18
        spacing: 8
        Kirigami.Icon {
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            source: card.media ? card.media.iconName : ""
            fallback: "media-playback-start"
        }
        WinText {
            anchors.verticalCenter: parent.verticalCenter
            text: card.media ? card.media.identity : ""
        }
    }

    Column {
        anchors { left: parent.left; leftMargin: WinTheme.padding; right: art.left; rightMargin: 16 }
        y: 56
        spacing: 2
        WinText {
            width: parent.width
            text: card.media ? card.media.title : ""
            font.weight: Font.DemiBold
        }
        WinText {
            width: parent.width
            text: card.media ? card.media.artist : ""
            color: WinTheme.textSecondary
        }
    }

    Rectangle {
        id: art
        anchors { right: parent.right; rightMargin: WinTheme.padding }
        y: 48
        width: 58
        height: 58
        radius: WinTheme.controlRadius
        color: WinTheme.control
        visible: artImage.status === Image.Ready
        Image {
            id: artImage
            anchors.fill: parent
            anchors.margins: 1
            source: card.media ? card.media.artUrl : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: 116
            sourceSize.height: 116
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 118
        spacing: 26
        WinIconButton {
            width: 40
            height: 40
            glyph: "previous"
            tooltip: "Previous"
            enabled: card.media ? card.media.canPrevious : false
            onClicked: card.media.previous()
        }
        WinIconButton {
            width: 40
            height: 40
            glyph: card.media && card.media.playing ? "pause" : "play"
            tooltip: card.media && card.media.playing ? "Pause" : "Play"
            enabled: card.media ? card.media.canPlayPause : false
            onClicked: card.media.playPause()
        }
        WinIconButton {
            width: 40
            height: 40
            glyph: "next"
            tooltip: "Next"
            enabled: card.media ? card.media.canNext : false
            onClicked: card.media.next()
        }
    }
}
