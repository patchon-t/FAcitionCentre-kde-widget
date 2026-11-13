#!/bin/sh
set -e
ID=com.techbypatch.quicksettings
kpackagetool6 -t Plasma/Applet -r "$ID"
echo
echo "Removed. Restart plasmashell to unload it:"
echo "    systemctl --user restart plasma-plasmashell"
