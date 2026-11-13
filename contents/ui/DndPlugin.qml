/*
 * Do Not Disturb through Plasma's own notification settings
 * (org.kde.notificationmanager, shipped with plasma-workspace).
 * Same mechanism the stock Notifications applet uses, so the bell icon
 * in the system tray stays in sync. Signal driven, no polling.
 */
import QtQuick
import org.kde.notificationmanager as NotificationManager

Item {
    readonly property bool inhibited: {
        const until = settings.notificationsInhibitedUntil
        const untilActive = until && !isNaN(until.getTime()) && Date.now() < until.getTime()
        return Boolean(untilActive || settings.notificationsInhibitedByApplication)
    }

    function setInhibited(on) {
        if (on) {
            const d = new Date()
            d.setFullYear(d.getFullYear() + 1)
            settings.notificationsInhibitedUntil = d
        } else {
            settings.notificationsInhibitedUntil = undefined
            settings.revokeApplicationInhibitions()
        }
        settings.save()
    }

    NotificationManager.Settings {
        id: settings
        live: true
    }
}
