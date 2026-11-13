#!/bin/sh
# Installs (or upgrades) the plasmoid for the current user. No root needed.
set -e
cd "$(dirname "$0")"
ID=com.techbypatch.quicksettings

if ! command -v kpackagetool6 >/dev/null 2>&1; then
    echo "kpackagetool6 not found (Debian: apt install kpackagetool6, or libkf6package-bin on older releases)" >&2
    exit 1
fi

if kpackagetool6 -t Plasma/Applet -s "$ID" >/dev/null 2>&1; then
    kpackagetool6 -t Plasma/Applet -u .
else
    kpackagetool6 -t Plasma/Applet -i .
fi

echo
echo "Done. Restart plasmashell so it picks up the new version:"
echo "    systemctl --user restart plasma-plasmashell"
echo "Then: right-click the panel > Add Widgets > \"Quick Settings\"."
