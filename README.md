# FAcitionCentre-kde-widget

A control center widget for KDE Plasma 6 that feels familiar if you come from Windows: a Windows 11 style Quick Settings popup.

Plugin ID: `com.techbypatch.quicksettings`

A panel widget that opens a Windows 11 style Quick Settings popup: six toggle
tiles, brightness and volume sliders, and a footer with battery, edit and
settings buttons. Colours come from the Plasma theme (light/dark and accent
colour are followed automatically).

> **Status:** written against the Plasma 6 APIs and smoke-tested with stubbed
> KDE modules and fake CLI tools. It has **not yet been run inside a real
> plasmashell**. Run `./check-env.sh` first and test each tile; see
> "Testing" below.

## Features

| Tile | What it does | Backend |
|---|---|---|
| Wi-Fi | Radio on/off, label shows the connected network. `>` lists networks; click to connect/disconnect, inline password prompt | `nmcli` (CLI) |
| Bluetooth | Adapter on/off, label shows the connected device. `>` lists paired devices; click to connect/disconnect | `bluetoothctl` (CLI) |
| Airplane mode | Blocks/unblocks all radios; Wi-Fi and Bluetooth tiles are greyed out while on | `rfkill block all`, falls back to `nmcli radio all off` + `bluetoothctl power off` |
| Night light | Enables/disables KWin Night Light | read: `org.kde.KWin.NightLight.enabled` (D-Bus); write: `kwriteconfig6` (kwinrc `NightColor/Active`) + `KWin reconfigure` |
| Do not disturb | Plasma notification DND, in sync with the tray bell | `org.kde.notificationmanager` QML plugin |
| Project | Opens the display-switch OSD (same as Meta+P) | `org.kde.kscreen.osdService.showActionSelector` (D-Bus); falls back to opening the Display KCM |

| Row | What it does | Backend |
|---|---|---|
| Brightness | Slider; row is hidden when no controllable display is found | PowerDevil `BrightnessControl` D-Bus (`brightness`, `brightnessMax`, `setBrightnessSilent`) |
| Volume | Slider, click the icon to mute, `>` picks the output device | `org.kde.plasma.private.volume` QML plugin; falls back to `wpctl` |
| Battery (footer) | Icon, percentage, charging state; hidden when there is no battery | Plasma5Support `powermanagement` engine; falls back to `/sys/class/power_supply/BAT*` |

### Panel icons

Like the Windows 11 taskbar, the panel button shows **network, volume and
battery icons** side by side (stacked in a vertical panel) with one shared
hover highlight. Click opens the popup; scrolling over it changes the volume
in 5 % steps. The tooltip summarises the network, volume and battery.

- Network icon: taken from plasma-nm (`org.kde.plasma.networkmanagement`), the
  same icon the stock Networks applet shows, including Wi-Fi strength, wired
  and VPN; falls back to icons computed from `nmcli` if that module is missing.
- Battery icon is hidden on machines without a battery; volume icon is hidden
  when no audio backend is found.

Plasma's own Networks, Audio Volume and Power and Battery icons will still be
in the system tray. To get the Windows look, hide them: right-click the
system tray → *Configure System Tray…* → *Entries* → set those three to
*Disabled* (or *Always hidden*).

Other behaviour:

- Sub-pages slide in inside the popup (200 ms) with a back arrow; tile colours animate (150 ms).
- **Edit** (pencil): click a tile to hide/show it, arrows reorder. Saved to the widget config (`hiddenTiles`, `tileOrder`).
- **Settings** (gear): opens `systemsettings`.
- Tooltips on every tile and control. A tile whose backend is missing is disabled and its tooltip says what is missing; nothing is faked.
- No root needed for anything.

### How state stays in sync

- Signal driven: do not disturb, volume (plugin), battery (engine).
- Wi-Fi/Bluetooth/airplane: re-read when the `org.kde.plasma.networkmanagement` or `org.kde.bluezqt` QML modules report a change (used only as change notifiers; optional).
- Everything else (night light, brightness, wpctl volume, sysfs battery) is polled every 3 s **only while the popup is open**, in a single shell invocation.

## Install

```bash
./check-env.sh     # shows which backends exist on this machine
./install.sh       # kpackagetool6 -i (or -u when already installed)
systemctl --user restart plasma-plasmashell
```

Then right-click the panel → *Add Widgets…* → "Quick Settings", and drag it
next to the clock. Add it to the panel itself, not inside the system tray. Remove with `./uninstall.sh`.

## Testing without installing

```bash
plasmoidviewer -a . -l topedge -f horizontal
```

Suggested order, one backend at a time: Wi-Fi tile → Wi-Fi list → Bluetooth →
airplane mode → night light → do not disturb → Project → brightness → volume →
output picker → battery → edit mode. Launch from a terminal to see QML warnings.

## Dependencies (Debian package names)

Names are for Debian 13 "trixie" (Plasma 6.3); check with `apt search` on other releases.

| Needed for | Command / module | Package |
|---|---|---|
| Widget itself | Plasma 6 shell, `org.kde.notificationmanager` | `plasma-workspace` |
| Shell helper, battery | `org.kde.plasma.plasma5support` | `plasma5support` |
| Wi-Fi, airplane mode | `nmcli` | `network-manager` |
| Wi-Fi change notifications (optional) | `org.kde.plasma.networkmanagement` | `plasma-nm` |
| Bluetooth | `bluetoothctl` (BlueZ ≥ 5.65) | `bluez` |
| Bluetooth change notifications (optional) | `org.kde.bluezqt` | `qml6-module-org-kde-bluezqt` (pulled in by `bluedevil`) |
| Airplane mode | `rfkill` | `rfkill` |
| Night light, Project, brightness | `qdbus6` | `qdbus-qt6` (older releases: `qt6-tools-dev-tools`) |
| Night light | `kwriteconfig6`, `kreadconfig6` | `libkf6config-bin` |
| Project | KScreen OSD service | `kscreen` |
| Brightness | PowerDevil | `powerdevil` |
| Volume | `org.kde.plasma.private.volume` | `plasma-pa` |
| Volume fallback | `wpctl` | `wireplumber` |
| Settings button, KCM fallbacks | `systemsettings`, `kcmshell6` | `systemsettings`, `kde-cli-tools` |
| Install / test | `kpackagetool6`, `plasmoidviewer` | `kpackagetool6`, `plasma-sdk` |

## Known limitations

- **Popup corner radius** comes from the Plasma theme's dialog frame; a plasmoid cannot override it. Tiles and footer use their own ~6 px radius.
- **Popup height** is a layout hint (about 360×380 at the default font); Plasma remembers a size if you resize the popup.
- **Wi-Fi password** is passed to `nmcli` on its command line, so it is briefly visible in the process list to other processes of your user. Enterprise (802.1X) and hidden networks are not handled; use the stock network applet for those.
- **Wi-Fi label** is the NetworkManager connection name, which is normally the SSID.
- **Night light** toggles the *enabled* setting. With a schedule (sunset to sunrise or custom times) the tile can be on while the screen is not tinted during the day, as on Windows.
- **Airplane mode** via `rfkill` needs access to `/dev/rfkill` (granted to the logged-in user by systemd-logind on Debian). Turning it off unblocks all radios rather than restoring the previous Wi-Fi/Bluetooth state. Without `rfkill`, "all visible radios are off" is shown as airplane mode.
- **Bluetooth** lists paired devices only; pairing opens the Bluetooth settings. Only the default adapter is controlled.
- **Brightness** controls what PowerDevil's legacy `BrightnessControl` interface exposes (the primary display). On a desktop PC with DDC/CI monitors Plasma 6.2+ may expose it too; otherwise the row is hidden.
- **Volume** slider tops out at 100 %; raise above that from the stock audio applet.
- **Panel icons, without plasma-nm:** the fallback network icon gets its Wi-Fi strength from `nmcli`, which is only re-read on network change events and while the popup is open, so the strength bars can lag.
- **Edit mode** has hide/show and arrow reordering; no drag and drop.
- UI strings are English only (no i18n catalog).
- KDE Connect is not used.

## License

GPL-3.0, see [LICENSE](LICENSE).
