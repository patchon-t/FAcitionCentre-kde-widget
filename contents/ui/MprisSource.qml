/*
 * Media player state from Plasma's MPRIS plugin (org.kde.plasma.private.mpris),
 * the one the stock Media Player applet uses. Loaded through a Loader: if it
 * is missing, the media card is simply not shown.
 */
import QtQuick
import org.kde.plasma.private.mpris as Mpris

Item {
    readonly property var player: mpris.currentPlayer
    readonly property string title: player ? String(player.track || "") : ""
    readonly property string artist: player ? String(player.artist || "") : ""
    readonly property string artUrl: player ? String(player.artUrl || "") : ""
    readonly property string identity: player ? String(player.identity || "") : ""
    readonly property string iconName: player ? String(player.iconName || "") : ""
    readonly property bool hasPlayer: title !== ""
    readonly property bool playing: player ? player.playbackStatus === Mpris.PlaybackStatus.Playing : false
    readonly property bool canPrevious: player ? Boolean(player.canGoPrevious) : false
    readonly property bool canNext: player ? Boolean(player.canGoNext) : false
    readonly property bool canPlayPause: player ? Boolean(player.canPlay || player.canPause) : false

    function previous() { if (player) player.Previous() }
    function next() { if (player) player.Next() }
    function playPause() { if (player) player.PlayPause() }

    Mpris.Mpris2Model {
        id: mpris
    }
}
