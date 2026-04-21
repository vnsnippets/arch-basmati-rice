pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Daemon.qml
// Centralised fire-and-forget process runner.
//
// Usage:
//   Command.execute(["nmcli", "dev", "wifi", "list"], (result, exitCode) => {
//       console.log(result.success, result.output, result.error);
//   });
//
// The callback receives:
//   result   – { success: bool, output: string, error: string, exitCode: int }
//   exitCode – convenience duplicate of result.exitCode
//

Singleton {
    id: command

    /// All currently running managed processes.
    property var processes: []

    /**
     * Execute a command and call back when it finishes.
     *
     * @param args     - string[] command + arguments
     * @param callback - function(result, exitCode)
     *                   result = { success, output, error, exitCode }
     * @returns the Process object (rarely needed by callers)
     */
    function execute(args, callback) {
        const p = _shell.createObject(command, {
            "command":  args,
            "_callback": callback
        });

        // Track active processes.
        let current = processes;
        current.push(p);
        processes = current;

        // Start the process.
        p.running = true;

        // Cleanup when done.
        p.runningChanged.connect(() => {
            if (p.running) return;

            // Remove from tracking list.
            let list = processes;
            const idx = list.indexOf(p);
            if (idx >= 0) {
                list.splice(idx, 1);
                processes = list;
            }

            // Build structured result.
            const out  = p._stdoutCollector.text.trim();
            const err  = p._stderrCollector.text.trim();
            const code = p._exitCode;
            const ok   = (code === 0);

            if (p._callback) {
                const result = { success: ok, output: out, error: err, exitCode: code };
                p._callback(result, code);
            }

            p.destroy(100);
        });

        return p;
    }

    // -------------------------------------------------------------------------
    // Internal process component
    // -------------------------------------------------------------------------

    Component {
        id: _shell

        Process {
            id: proc

            property var _callback:  null
            property int _exitCode:  0

            property alias _stdoutCollector: stdoutColl
            property alias _stderrCollector: stderrColl

            // Normalise locale so output is always ASCII-safe.
            environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })

            stdout: StdioCollector { id: stdoutColl }
            stderr: StdioCollector { id: stderrColl }

            onExited: (code) => { proc._exitCode = code; }
        }
    }
}
