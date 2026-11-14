/*
 * All system state + actions for the Quick Settings popup.
 *
 * Backends (see README for the full table):
 *   Wi-Fi / airplane   nmcli + rfkill              (CLI, change-notified by plasma-nm plugin if present)
 *   Bluetooth          bluetoothctl                (CLI, change-notified by org.kde.bluezqt if present)
 *   Night light        KWin NightLight D-Bus (read) + kwriteconfig6 & KWin reconfigure (write)
 *   Do not disturb     org.kde.notificationmanager QML plugin (signals)
 *   Project            org.kde.kscreen.osdService D-Bus
 *   Brightness         PowerDevil BrightnessControl D-Bus
 *   Volume             org.kde.plasma.private.volume QML plugin (signals), wpctl fallback
 *   Battery            Plasma5Support "powermanagement" engine (signals), sysfs fallback
 *
 * Everything that has no signal source is polled every 3 s, and only while
 * `active` (popup open) is true.
 */
import QtQuick
import org.kde.plasma.plasma5support as P5Support

Item {
    id: backend
    visible: false

    // Set by main.qml: true while the popup is open.
    property bool active: false

    // ---- capability probe ---------------------------------------------------
    property bool probed: false
    property var tools: ({})          // { nmcli: true, ... }
    property string qdbus: ""         // qdbus6 | qdbus-qt6 | qdbus | ""

    function has(tool) { return tools[tool] === true }

    // ---- public state -------------------------------------------------------
    // Wi-Fi
    property bool wifiAvailable: false       // nmcli present and a wifi device exists
    property bool wifiEnabled: false
    property string wifiSsid: ""
    property int wifiSignal: -1              // strength of the connected network, -1 = unknown
    property bool wiredConnected: false
    property var wifiNetworks: []            // [{ ssid, signal, security, secured, inUse, saved }]
    property bool wifiScanning: false
    property string wifiBusySsid: ""
    property string wifiError: ""
    property string wifiNeedsPassword: ""    // saved profile that failed: ask for the password again

    // Bluetooth
    property bool btAvailable: false         // bluetoothctl present and an adapter exists
    property bool btEnabled: false
    property var btConnected: []             // [{ mac, name }]
    property var btDevices: []               // paired: [{ mac, name, connected }]
    property string btBusyMac: ""
    property string btError: ""

    // Airplane mode
    readonly property bool airplaneAvailable: has("rfkill") || has("nmcli")
    property bool airplaneMode: false

    // Night light
    readonly property bool nightLightAvailable: qdbus !== "" && has("kwriteconfig6")
    property bool nightLight: false

    // Do not disturb
    readonly property bool dndAvailable: dndLoader.status === Loader.Ready
    readonly property bool dnd: dndAvailable ? dndLoader.item.inhibited : false

    // Project
    readonly property bool projectAvailable: qdbus !== ""

    // Brightness
    property bool brightnessAvailable: false
    property int brightnessMax: 0
    property real brightness: 0              // 0..1

    // Volume
    readonly property bool volumeUsesPlugin: volumeLoader.status === Loader.Ready
    readonly property bool volumeAvailable: volumeUsesPlugin ? volumeLoader.item.available : wpctlAvailable
    readonly property real volume: volumeUsesPlugin ? volumeLoader.item.volume : wpctlVolume
    readonly property bool muted: volumeUsesPlugin ? volumeLoader.item.muted : wpctlMuted
    readonly property var sinks: volumeUsesPlugin ? volumeLoader.item.sinks : wpctlSinks
    property bool wpctlAvailable: false
    property real wpctlVolume: 0
    property bool wpctlMuted: false
    property var wpctlSinks: []              // [{ name, isDefault, wpId }]

    // Battery
    readonly property bool batteryUsesEngine: pmSource.data["Battery"] !== undefined
                                              && pmSource.data["Battery"]["Has Battery"] !== undefined
    readonly property bool hasBattery: batteryUsesEngine ? Boolean(pmSource.data["Battery"]["Has Battery"]) : sysBattery
    readonly property int batteryPercent: batteryUsesEngine ? Number(pmSource.data["Battery"]["Percent"] || 0) : sysBatteryPercent
    readonly property string batteryState: batteryUsesEngine ? String(pmSource.data["Battery"]["State"] || "") : sysBatteryState
    readonly property bool batteryCharging: batteryState === "Charging"
    readonly property bool batteryFull: batteryState === "FullyCharged" || batteryState === "Full"
    property bool sysBattery: false
    property int sysBatteryPercent: 0
    property string sysBatteryState: ""

    // ---- Windows-style glyphs (contents/icons/*.svg) --------------------------
    // Wi-Fi bars 1..4 from a 0..100 signal (-1 = unknown -> full bars).
    function wifiGlyphFor(signal) {
        if (signal < 0) {
            return "wifi-4"
        }
        return "wifi-" + (signal >= 75 ? 4 : signal >= 50 ? 3 : signal >= 25 ? 2 : 1)
    }

    // plasma-nm's icon (signal driven, same as the stock applet). We only
    // take the Wi-Fi strength from it; the rest of the state comes from nmcli.
    readonly property string nmIconName: nmIcon.status === Loader.Ready ? String(nmIcon.item.iconName || "") : ""
    readonly property int nmSignal: {
        const m = nmIconName.match(/wireless.*?(\d+)/)
        return m ? parseInt(m[1]) : -1
    }
    readonly property int currentSignal: nmSignal >= 0 ? nmSignal : wifiSignal

    readonly property bool networkIconAvailable: has("nmcli")
    readonly property string networkGlyph: {
        if (airplaneMode) {
            return "airplane"
        }
        if (wiredConnected) {
            return "ethernet"
        }
        if (wifiAvailable && wifiEnabled && wifiSsid !== "") {
            return wifiGlyphFor(currentSignal)
        }
        if (wifiAvailable && !wifiEnabled) {
            return "wifi-off"
        }
        return "globe-off"
    }
    readonly property string networkStatusText: {
        if (airplaneMode) {
            return "Airplane mode"
        }
        if (wiredConnected) {
            return "Wired connection"
        }
        if (!wifiAvailable) {
            return "Not connected"
        }
        if (!wifiEnabled) {
            return "Wi-Fi off"
        }
        if (wifiSsid === "") {
            return "Not connected"
        }
        return wifiSsid + (currentSignal >= 0 ? " (" + currentSignal + "%)" : "")
    }

    readonly property string volumeGlyph: muted || volume <= 0 ? "speaker-mute"
                                        : volume < 0.34 ? "speaker-1"
                                        : volume < 0.67 ? "speaker-2" : "speaker-3"

    readonly property string batteryGlyph: "battery-" + Math.max(0, Math.min(10, Math.round(batteryPercent / 10)))
                                           + (batteryCharging || batteryFull && pluggedIn ? "-charging" : "")
    readonly property bool pluggedIn: batteryUsesEngine ? Boolean(pmSource.data["AC Adapter"] && pmSource.data["AC Adapter"]["Plugged in"])
                                                         : batteryCharging
    readonly property string batteryStatusText: batteryPercent + "%"
                                                + (batteryCharging ? ", charging" : batteryFull ? ", fully charged" : "")

    // ---- plumbing -----------------------------------------------------------
    readonly property string prelude: 'export LC_ALL=C PATH="$PATH:/usr/sbin:/sbin:/usr/lib/qt6/bin"; '

    // Bumped by every user action so a poll that started before the action
    // cannot overwrite the new state with stale data.
    property int generation: 0
    property bool pollRunning: false

    function sh(cmd, callback) { exec.run(prelude + cmd, callback) }
    function q(s) { return exec.quote(s) }
    function dbus(args) { return qdbus + " " + args }

    Exec { id: exec }

    Loader { id: dndLoader; source: "DndPlugin.qml" }
    Loader { id: volumeLoader; source: "VolumePlugin.qml" }
    Loader { id: nmNotifier; source: "NmNotifier.qml" }
    Loader { id: btNotifier; source: "BtNotifier.qml" }
    // Separate loader so a plasma-nm API difference can't take the notifier down with it.
    Loader { id: nmIcon; source: "NmIcon.qml" }

    Connections {
        target: nmNotifier.item
        function onChanged() { notifyDebounce.restart() }
    }
    Connections {
        target: btNotifier.item
        function onChanged() { notifyDebounce.restart() }
    }
    Timer {
        id: notifyDebounce
        interval: 250
        onTriggered: backend.refresh(["wifi", "bt", "airplane"])
    }

    P5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }

    Timer {
        id: pollTimer
        interval: 3000
        repeat: true
        running: backend.active && backend.probed
        triggeredOnStart: true
        onTriggered: backend.refresh()
    }
    Timer {
        id: followUp
        interval: 1500
        onTriggered: backend.refresh()
    }

    Component.onCompleted: probe()

    function probe() {
        sh('for c in nmcli bluetoothctl rfkill wpctl kwriteconfig6 kreadconfig6 kcmshell6 systemsettings timeout; do '
           + 'command -v $c >/dev/null 2>&1 && echo "tool:$c"; done; '
           + 'for c in qdbus6 qdbus-qt6 qdbus; do if command -v $c >/dev/null 2>&1; then echo "qdbus:$c"; break; fi; done',
           (out) => {
               const t = {}
               let qd = ""
               for (const line of out.split("\n")) {
                   if (line.startsWith("tool:")) {
                       t[line.substring(5).trim()] = true
                   } else if (line.startsWith("qdbus:")) {
                       qd = line.substring(6).trim()
                   }
               }
               tools = t
               qdbus = qd
               probed = true
               refresh()
           })
    }

    // ---- polling ------------------------------------------------------------
    readonly property string brightnessPath: "org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl org.kde.Solid.PowerManagement.Actions.BrightnessControl."
    // `timeout` keeps a dead bluetoothd from hanging the poll.
    readonly property string btctl: (has("timeout") ? "timeout 4 " : "") + "bluetoothctl "

    function sectionCommand(name) {
        switch (name) {
        case "wifi":
            return has("nmcli") ? "nmcli -t -f WIFI radio 2>/dev/null; nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null; "
                                  + 'echo "--"; nmcli -t -f IN-USE,SIGNAL device wifi list --rescan no 2>/dev/null' : ""
        case "bt":
            return has("bluetoothctl") ? btctl + 'show 2>/dev/null | grep -m1 "Powered:"; echo "--"; ' + btctl + "devices Connected 2>/dev/null" : ""
        case "airplane":
            return has("rfkill") ? "rfkill -n -o TYPE,SOFT 2>/dev/null" : ""
        case "night":
            if (qdbus === "") {
                return ""
            }
            return dbus("org.kde.KWin /org/kde/KWin/NightLight org.kde.KWin.NightLight.enabled 2>/dev/null")
                    + " || " + dbus("org.kde.KWin /ColorCorrect org.kde.kwin.ColorCorrect.enabled 2>/dev/null")
                    + (has("kreadconfig6") ? " || kreadconfig6 --file kwinrc --group NightColor --key Active --default false 2>/dev/null" : "")
        case "brightness":
            return qdbus !== "" ? dbus(brightnessPath + "brightnessMax 2>/dev/null") + "; " + dbus(brightnessPath + "brightness 2>/dev/null") : ""
        case "volume":
            return !volumeUsesPlugin && has("wpctl") ? "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null" : ""
        case "battery":
            return batteryUsesEngine ? "" : 'for b in /sys/class/power_supply/BAT*; do if [ -r "$b/capacity" ]; then echo "$(cat "$b/capacity") $(cat "$b/status")"; break; fi; done'
        }
        return ""
    }

    function refresh(names) {
        if (!probed) {
            return
        }
        const full = names === undefined
        if (full) {
            if (pollRunning) {
                return
            }
            pollRunning = true
            names = ["wifi", "bt", "airplane", "night", "brightness", "volume", "battery"]
        }
        let script = ""
        for (const n of names) {
            const c = sectionCommand(n)
            if (c !== "") {
                script += 'echo "@@' + n + '"; ' + c + "; "
            }
        }
        if (script === "") {
            pollRunning = false
            return
        }
        const gen = generation
        sh(script, (out) => {
            if (full) {
                pollRunning = false
            }
            if (gen !== generation) {
                return // a user action happened meanwhile; its own refresh follows
            }
            let current = ""
            const sections = {}
            for (const line of out.split("\n")) {
                if (line.startsWith("@@")) {
                    current = line.substring(2).trim()
                    sections[current] = []
                } else if (current !== "" && line.trim() !== "") {
                    sections[current].push(line)
                }
            }
            for (const key in sections) {
                parseSection(key, sections[key])
            }
            inferAirplane()
        })
    }

    // Split one line of `nmcli -t` output into n fields (":"-separated, "\" escapes).
    function nmSplit(line, n) {
        const out = []
        let cur = ""
        for (let i = 0; i < line.length; ++i) {
            const c = line[i]
            if (c === "\\" && i + 1 < line.length) {
                cur += line[++i]
            } else if (c === ":" && out.length < n - 1) {
                out.push(cur)
                cur = ""
            } else {
                cur += c
            }
        }
        out.push(cur)
        return out
    }

    function stripAnsi(s) { return s.replace(/\x1b\[[0-9;]*[A-Za-z]/g, "").replace(/\x01|\x02/g, "") }

    function parseBtDeviceLines(lines) {
        const list = []
        for (const raw of lines) {
            const m = stripAnsi(raw).match(/^\s*Device\s+([0-9A-Fa-f:]{17})\s*(.*)$/)
            if (m) {
                list.push({ mac: m[1], name: m[2].trim() || m[1] })
            }
        }
        return list
    }

    function parseSection(name, lines) {
        switch (name) {
        case "wifi": {
            const sep = lines.indexOf("--")
            const devices = sep >= 0 ? lines.slice(0, sep) : lines
            let hasDevice = false
            let wired = false
            let ssid = ""
            for (let i = 1; i < devices.length; ++i) {
                const f = nmSplit(devices[i], 3)
                if (f[0] === "wifi") {
                    hasDevice = true
                    if (f[1] === "connected" && ssid === "") {
                        ssid = f[2]
                    }
                } else if (f[0] === "ethernet" && f[1] === "connected") {
                    wired = true
                }
            }
            let signal = -1
            for (const l of (sep >= 0 ? lines.slice(sep + 1) : [])) {
                const f = nmSplit(l, 2)
                if (f[0].trim() === "*") {
                    signal = parseInt(f[1])
                    break
                }
            }
            wifiAvailable = hasDevice
            wiredConnected = wired
            wifiEnabled = devices.length > 0 && devices[0].trim() === "enabled"
            wifiSsid = wifiEnabled ? ssid : ""
            wifiSignal = wifiSsid !== "" && !isNaN(signal) ? signal : -1
            break
        }
        case "bt": {
            const sep = lines.indexOf("--")
            const head = sep >= 0 ? lines.slice(0, sep) : lines
            const tail = sep >= 0 ? lines.slice(sep + 1) : []
            btAvailable = head.length > 0
            btEnabled = head.length > 0 && /Powered:\s*yes/.test(head[0])
            btConnected = btEnabled ? parseBtDeviceLines(tail) : []
            break
        }
        case "airplane": {
            let total = 0
            let blocked = 0
            for (const l of lines) {
                const f = l.trim().split(/\s+/)
                if (f.length >= 2) {
                    ++total
                    if (f[1] === "blocked") {
                        ++blocked
                    }
                }
            }
            if (total > 0) {
                airplaneMode = blocked === total
            } else {
                inferAirplane()
            }
            break
        }
        case "night":
            nightLight = lines.length > 0 && lines[0].trim() === "true"
            break
        case "brightness": {
            const max = lines.length > 1 ? parseInt(lines[0]) : NaN
            const cur = lines.length > 1 ? parseInt(lines[1]) : NaN
            if (isNaN(max) || isNaN(cur) || max <= 0) {
                brightnessAvailable = false
            } else {
                brightnessMax = max
                brightness = Math.max(0, Math.min(1, cur / max))
                brightnessAvailable = true
            }
            break
        }
        case "volume": {
            const m = lines.length > 0 ? lines[0].match(/Volume:\s*([0-9.]+)/) : null
            wpctlAvailable = m !== null
            if (m) {
                wpctlVolume = Math.max(0, Math.min(1, parseFloat(m[1])))
                wpctlMuted = lines[0].indexOf("MUTED") >= 0
            }
            break
        }
        case "battery": {
            const m = lines.length > 0 ? lines[0].match(/^(\d+)\s+(.*)$/) : null
            sysBattery = m !== null
            if (m) {
                sysBatteryPercent = parseInt(m[1])
                sysBatteryState = m[2].trim()
            }
            break
        }
        }
    }

    // Without rfkill we cannot read a real "airplane" flag; treat
    // "every radio we can see is off" as airplane mode.
    function inferAirplane() {
        if (has("rfkill")) {
            return
        }
        airplaneMode = (wifiAvailable || btAvailable) && (!wifiAvailable || !wifiEnabled) && (!btAvailable || !btEnabled)
    }

    function acted() {
        ++generation
        pollRunning = false
    }
    function refreshAfterAction() {
        refresh()
        followUp.restart()
    }

    // ---- actions: radios ----------------------------------------------------
    function setWifi(on) {
        acted()
        wifiEnabled = on
        if (!on) {
            wifiSsid = ""
        }
        sh("nmcli radio wifi " + (on ? "on" : "off"), refreshAfterAction)
    }

    function setBluetooth(on) {
        acted()
        btEnabled = on
        if (!on) {
            btConnected = []
        }
        sh((on && has("rfkill") ? "rfkill unblock bluetooth 2>/dev/null; " : "") + btctl + "power " + (on ? "on" : "off"), refreshAfterAction)
    }

    function setAirplane(on) {
        acted()
        airplaneMode = on
        const state = on ? "off" : "on"
        const viaNm = (has("nmcli") ? "nmcli radio all " + state + "; " : "")
                    + (has("bluetoothctl") ? btctl + "power " + state + "; " : "") + "true"
        const cmd = has("rfkill") ? "rfkill " + (on ? "block" : "unblock") + " all 2>/dev/null || { " + viaNm + "; }" : viaNm
        sh(cmd, refreshAfterAction)
    }

    // ---- actions: wifi networks ---------------------------------------------
    function scanWifi() {
        if (!has("nmcli") || wifiScanning) {
            return
        }
        wifiScanning = true
        sh('nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan auto 2>/dev/null; echo "@@saved"; '
           + "nmcli -t -f TYPE,NAME connection show 2>/dev/null", (out) => {
            wifiScanning = false
            const saved = {}
            const bySsid = {}
            let inSaved = false
            for (const line of out.split("\n")) {
                if (line === "@@saved") {
                    inSaved = true
                } else if (line === "") {
                    continue
                } else if (inSaved) {
                    const f = nmSplit(line, 2)
                    if (f[0] === "802-11-wireless") {
                        saved[f[1]] = true
                    }
                } else {
                    const f = nmSplit(line, 4)
                    if (f.length < 4 || f[3] === "") {
                        continue // hidden network
                    }
                    const net = {
                        ssid: f[3],
                        signal: parseInt(f[1]) || 0,
                        security: f[2] === "--" ? "" : f[2],
                        inUse: f[0].trim() === "*",
                        saved: false
                    }
                    net.secured = net.security !== ""
                    const old = bySsid[net.ssid]
                    if (!old || net.inUse || (!old.inUse && net.signal > old.signal)) {
                        bySsid[net.ssid] = net
                    }
                }
            }
            const list = []
            for (const ssid in bySsid) {
                bySsid[ssid].saved = saved[ssid] === true
                list.push(bySsid[ssid])
            }
            list.sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal))
            wifiNetworks = list
        })
    }

    // Returns true if a password is needed first (page then prompts and calls
    // again with the password).
    function connectWifi(net, password) {
        wifiError = ""
        if (net.inUse) {
            wifiBusySsid = net.ssid
            sh("nmcli connection down id " + q(net.ssid) + " 2>&1", (out, code) => wifiActionDone(net, code, out, false))
            return false
        }
        const havePassword = password !== undefined && password !== ""
        if (!havePassword && net.secured && (!net.saved || wifiNeedsPassword === net.ssid)) {
            return true
        }
        acted()
        wifiBusySsid = net.ssid
        let cmd
        if (havePassword) {
            // Drop a stale profile first so the new password is actually used.
            cmd = (net.saved ? "nmcli connection delete id " + q(net.ssid) + " >/dev/null 2>&1; " : "")
                + "nmcli device wifi connect " + q(net.ssid) + " password " + q(password) + " 2>&1"
        } else if (net.saved) {
            cmd = "nmcli connection up id " + q(net.ssid) + " 2>&1"
        } else {
            cmd = "nmcli device wifi connect " + q(net.ssid) + " 2>&1"
        }
        sh(cmd, (out, code) => wifiActionDone(net, code, out, havePassword))
        return false
    }

    function wifiActionDone(net, code, out, usedPassword) {
        wifiBusySsid = ""
        if (code === 0) {
            wifiNeedsPassword = ""
        } else {
            wifiError = out.trim().split("\n").pop() || ("nmcli failed (exit code " + code + ")")
            if (!usedPassword && net.saved && net.secured && !net.inUse) {
                wifiNeedsPassword = net.ssid
            }
            if (usedPassword) {
                // nmcli leaves a broken profile behind after a wrong password.
                sh("nmcli connection delete id " + q(net.ssid) + " >/dev/null 2>&1")
            }
        }
        refreshAfterAction()
        scanWifi()
    }

    // ---- actions: bluetooth devices -----------------------------------------
    function refreshBtDevices() {
        if (!has("bluetoothctl")) {
            return
        }
        sh(btctl + 'devices Paired 2>/dev/null; echo "--"; ' + btctl + "devices Connected 2>/dev/null", (out) => {
            const lines = out.split("\n")
            const sep = lines.indexOf("--")
            const paired = parseBtDeviceLines(sep >= 0 ? lines.slice(0, sep) : lines)
            const connected = {}
            for (const d of parseBtDeviceLines(sep >= 0 ? lines.slice(sep + 1) : [])) {
                connected[d.mac] = true
            }
            for (const d of paired) {
                d.connected = connected[d.mac] === true
            }
            paired.sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
            btDevices = paired
        })
    }

    function toggleBtDevice(dev) {
        if (!/^[0-9A-Fa-f:]{17}$/.test(dev.mac) || btBusyMac !== "") {
            return
        }
        acted()
        btError = ""
        btBusyMac = dev.mac
        sh((has("timeout") ? "timeout 20 " : "") + "bluetoothctl " + (dev.connected ? "disconnect " : "connect ") + dev.mac + " 2>&1", (out, code) => {
            btBusyMac = ""
            const text = stripAnsi(out)
            if (code !== 0 || /Failed to (dis)?connect/.test(text)) {
                const failed = text.split("\n").filter(l => /Failed|not available|Error/i.test(l)).pop()
                btError = (failed || "").trim() || ((dev.connected ? "Could not disconnect from " : "Could not connect to ") + dev.name)
            }
            refreshBtDevices()
            refreshAfterAction()
        })
    }

    // ---- actions: night light / dnd / project -------------------------------
    function setNightLight(on) {
        acted()
        nightLight = on
        sh("kwriteconfig6 --file kwinrc --group NightColor --key Active " + (on ? "true" : "false") + " && "
           + dbus("org.kde.KWin /KWin reconfigure >/dev/null 2>&1"), refreshAfterAction)
    }

    function setDnd(on) {
        if (dndAvailable) {
            dndLoader.item.setInhibited(on)
        }
    }

    function project() {
        sh(dbus("org.kde.kscreen.osdService /org/kde/kscreen/osdService org.kde.kscreen.osdService.showActionSelector >/dev/null 2>&1")
           + (has("kcmshell6") ? " || kcmshell6 kcm_kscreen >/dev/null 2>&1" : ""))
    }

    function openSystemSettings() {
        sh("systemsettings >/dev/null 2>&1 &")
    }
    function openKcm(name) {
        if (/^[a-z0-9_]+$/.test(name)) {
            sh("kcmshell6 " + name + " >/dev/null 2>&1 &")
        }
    }

    // ---- actions: brightness ------------------------------------------------
    property real pendingBrightness: -1
    Timer {
        id: brightnessThrottle
        interval: 60
        onTriggered: {
            if (backend.pendingBrightness < 0) {
                return
            }
            const value = Math.round(backend.pendingBrightness * backend.brightnessMax)
            backend.pendingBrightness = -1
            backend.sh(backend.dbus(backend.brightnessPath + "setBrightnessSilent " + value + " >/dev/null 2>&1"))
        }
    }
    function setBrightness(fraction) {
        acted()
        brightness = fraction
        pendingBrightness = fraction
        if (!brightnessThrottle.running) {
            brightnessThrottle.start()
        }
    }

    // ---- actions: volume ----------------------------------------------------
    property real pendingVolume: -1
    Timer {
        id: volumeThrottle
        interval: 60
        onTriggered: {
            if (backend.pendingVolume < 0) {
                return
            }
            const value = backend.pendingVolume.toFixed(2)
            backend.pendingVolume = -1
            backend.sh("wpctl set-volume @DEFAULT_AUDIO_SINK@ " + value)
        }
    }
    function setVolume(fraction) {
        if (volumeUsesPlugin) {
            volumeLoader.item.setVolume(fraction)
            return
        }
        acted()
        wpctlVolume = fraction
        pendingVolume = fraction
        if (!volumeThrottle.running) {
            volumeThrottle.start()
        }
    }

    function toggleMute() {
        if (volumeUsesPlugin) {
            volumeLoader.item.setMuted(!muted)
            return
        }
        acted()
        wpctlMuted = !wpctlMuted
        sh("wpctl set-mute @DEFAULT_AUDIO_SINK@ " + (wpctlMuted ? "1" : "0"), () => refresh(["volume"]))
    }

    function refreshSinks() {
        if (volumeUsesPlugin || !has("wpctl")) {
            return
        }
        sh("wpctl status 2>/dev/null", (out) => {
            // Parse the "Sinks:" block of the Audio section, e.g.
            //  │  *   53. Built-in Audio Analog Stereo        [vol: 0.40]
            const list = []
            let inSinks = false
            for (const line of out.split("\n")) {
                if (/^\s*[│├└|]?\s*[├└]?─?\s*Sinks:/.test(line)) {
                    inSinks = true
                    continue
                }
                if (!inSinks) {
                    continue
                }
                const m = line.match(/^[\s│|]*(\*)?\s*(\d+)\.\s+(.*?)\s*(\[vol:[^\]]*\])?\s*$/)
                if (!m) {
                    if (list.length > 0 || /:\s*$/.test(line)) {
                        break // end of the first Sinks block (the audio one)
                    }
                    continue
                }
                list.push({ name: m[3], isDefault: m[1] === "*", wpId: parseInt(m[2]) })
            }
            wpctlSinks = list
        })
    }

    function setDefaultSink(entry) {
        if (volumeUsesPlugin) {
            volumeLoader.item.setDefault(entry)
            return
        }
        if (entry.wpId === undefined) {
            return
        }
        acted()
        sh("wpctl set-default " + Number(entry.wpId), () => {
            refreshSinks()
            refresh(["volume"])
        })
    }
}
