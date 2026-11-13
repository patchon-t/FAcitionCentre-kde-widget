#!/bin/sh
# Prints everything the plasmoid's backends depend on. Run it and paste the output if something misbehaves.
PATH="$PATH:/usr/sbin:/sbin:/usr/lib/qt6/bin"
echo "== Plasma =="
plasmashell --version 2>&1 || echo "plasmashell: MISSING"
echo "== Tools =="
for c in qdbus6 qdbus-qt6 qdbus nmcli bluetoothctl wpctl pactl rfkill kscreen-doctor kdeconnect-cli \
         plasmoidviewer kpackagetool6 kwriteconfig6 kreadconfig6 kcmshell6 systemsettings timeout; do
    printf '%-16s %s\n' "$c" "$(command -v "$c" 2>/dev/null || echo MISSING)"
done
echo "== QML modules =="
for d in /usr/lib/qt6/qml /usr/lib/*/qt6/qml /usr/lib64/qt6/qml; do
    [ -d "$d" ] || continue
    for m in org/kde/bluezqt org/kde/plasma/private/volume org/kde/plasma/networkmanagement \
             org/kde/notificationmanager org/kde/plasma/plasma5support; do
        printf '%-44s %s\n' "$m" "$([ -d "$d/$m" ] && echo "$d/$m" || echo MISSING)"
    done
done
Q=$(command -v qdbus6 || command -v qdbus-qt6 || command -v qdbus)
if [ -n "$Q" ]; then
    echo "== D-Bus backends =="
    printf 'NightLight.enabled:   '; "$Q" org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight.enabled 2>&1 | head -n1
    B=/org/kde/Solid/PowerManagement/Actions/BrightnessControl
    I=org.kde.Solid.PowerManagement.Actions.BrightnessControl
    printf 'brightnessMax:        '; "$Q" org.kde.Solid.PowerManagement $B $I.brightnessMax 2>&1 | head -n1
    printf 'brightness:           '; "$Q" org.kde.Solid.PowerManagement $B $I.brightness 2>&1 | head -n1
    printf 'KScreen OSD service:  '; "$Q" org.kde.kscreen.osdService /org/kde/kscreen/osdService 2>&1 | grep -c showActionSelector
fi
echo "== Radios =="
rfkill -n -o TYPE,SOFT,HARD 2>&1
nmcli -t -f WIFI radio 2>&1
echo "== Battery =="
ls /sys/class/power_supply/ 2>&1
