/*
 * Small reusable shell helper around the Plasma5Support "executable" engine.
 *
 *   Exec { id: exec }
 *   exec.run("nmcli radio wifi on", (stdout, exitCode, stderr) => { ... })
 *
 * Commands run through /bin/sh (dash on Debian), so keep them POSIX.
 */
import QtQuick
import org.kde.plasma.plasma5support as P5Support

P5Support.DataSource {
    id: exec

    engine: "executable"
    connectedSources: []

    property var _callbacks: ({})
    property int _seq: 0

    // Quote a string for safe use as a single shell argument.
    function quote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'"
    }

    function run(cmd, callback) {
        // The engine keys running processes by command string. A trailing
        // newline + shell comment makes every invocation unique, so two
        // identical commands issued back to back both get their callback.
        const source = cmd + "\n# qs-" + (++_seq)
        _callbacks[source] = callback || null
        connectSource(source)
    }

    onNewData: (source, data) => {
        const cb = _callbacks[source]
        delete _callbacks[source]
        disconnectSource(source)
        if (cb) {
            cb(String(data["stdout"] || ""), Number(data["exit code"] || 0), String(data["stderr"] || ""))
        }
    }
}
