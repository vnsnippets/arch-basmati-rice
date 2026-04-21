pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Services

// Networking.qml
// Two-Tier Reactive Networking Service
//
// Tier 1 – Global Monitor : persistent `gdbus monitor` on
//           /org/freedesktop/NetworkManager for connectivity &
//           active-connection changes.
// Tier 2 – Action / Detail layer : on-demand `nmcli` and `gdbus` calls
//           routed through Daemon.execute(), triggered by Tier 1 events
//           or explicit UI requests.
//
// Advanced hooks included:
//   • Captive-portal detection  (connectivity === 2 → xdg-open)
//   • Per-AP signal-strength subscription via a second gdbus monitor
//   • Metered-connection query
//   • PrimaryConnectionType detection for wired/wireless UI switching
//

Singleton {
    id: root

    // -----------------------------------------------------------------------
    // Public – Observable Properties
    // -----------------------------------------------------------------------

    /// True while gdbus monitor is receiving output from NetworkManager.
    readonly property bool isRunning: _nmRunning

    /// NM global connectivity:
    ///   0 = unknown, 1 = none, 2 = portal (captive), 3 = limited, 4 = full
    readonly property int connectivity: _connectivity

    /// SSID of the currently active Wi-Fi connection, or "" for wired/none.
    readonly property string activeSsid: _activeSsid

    /// Signal strength of the active AP (0–100), updated reactively via DBus.
    readonly property int signalStrength: _signalStrength

    /// True when the active primary connection is 802-3-ethernet (wired).
    readonly property bool isWired: _primaryConnectionType === "802-3-ethernet"

    /// True when Wi-Fi radio is enabled.
    readonly property bool wifiEnabled: _wifiEnabled

    /// Whether global nmcli networking is enabled.
    readonly property bool networkingEnabled: _networkingEnabled

    /// Flat list of visible Wi-Fi APs (populated by refreshWifiList / rescanWifi).
    /// Each entry: { ssid, strength, security, bars, active }
    readonly property var availableWifi: _availableWifi

    /// Flat list of saved connection profiles (populated by refreshKnownNetworks).
    /// Each entry: { name, type, uuid }
    readonly property var knownNetworks: _knownNetworks

    /// True while a Wi-Fi rescan + list is in-flight.
    readonly property bool scanning: wifiListProc.running || rescanProc.running

    // -----------------------------------------------------------------------
    // Signals
    // -----------------------------------------------------------------------

    /// Emitted when the UI should show a captive-portal browser prompt.
    signal captivePortalDetected()

    /// Emitted when a connection attempt fails (not a password issue).
    signal connectionFailed(string ssid)

    /// Emitted when a password is required to complete a connection attempt.
    signal passwordRequired(string ssid)

    // -----------------------------------------------------------------------
    // Internal mutable state
    // -----------------------------------------------------------------------

    property bool   _nmRunning:             false
    property int    _connectivity:          0
    property string _activeSsid:            ""
    property int    _signalStrength:        0
    property string _primaryConnectionType: ""
    property bool   _wifiEnabled:           true
    property bool   _networkingEnabled:     true
    property var    _availableWifi:         []
    property var    _knownNetworks:         []

    /// DBus object-path of the active AP, used by the signal-strength monitor.
    property string _activeApPath: ""

    // -----------------------------------------------------------------------
    // TIER 1 – Global DBus Monitor
    // -----------------------------------------------------------------------
    // Watches /org/freedesktop/NetworkManager for PropertiesChanged signals.
    // Key properties: Connectivity, PrimaryConnection, PrimaryConnectionType, State.
    // Not routed through Command because it is a persistent streaming process.

    Process {
        id: globalMonitor

        command: [
            "gdbus", "monitor",
            "--system",
            "--dest",        "org.freedesktop.NetworkManager",
            "--object-path", "/org/freedesktop/NetworkManager"
        ]
        running: true

        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })

        stdout: SplitParser {
            onRead: (line) => {
                // Any output confirms NM is alive.
                root._nmRunning = true;

                if (line.includes("'Connectivity'"))
                    root._parseConnectivity(line);

                // Phase 4: wired vs wireless switching.
                if (line.includes("'PrimaryConnectionType'"))
                    root._parsePrimaryConnectionType(line);

                // Active connection changed → refresh SSID + AP path.
                if (line.includes("'PrimaryConnection'") || line.includes("'ActiveConnections'"))
                    root._refreshActiveDetails();

                // Global NM state (up / down).
                if (line.includes("'State'"))
                    root._parseNmState(line);
            }
        }

        onExited: {
            root._nmRunning = false;
            globalMonitorRestartTimer.start();
        }
    }

    Timer {
        id: globalMonitorRestartTimer
        interval: 3000
        onTriggered: globalMonitor.running = true
    }

    // -----------------------------------------------------------------------
    // TIER 1-B – Per-AP Signal-Strength Monitor  (Advanced Hook B)
    // -----------------------------------------------------------------------
    // Subscribes to a specific AccessPoint DBus object so Strength updates
    // arrive reactively without any polling timer.
    // Not routed through Command because it is a persistent streaming process.

    Process {
        id: apStrengthMonitor

        command: []   // Set dynamically in _startApStrengthMonitor().
        running: false

        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })

        stdout: SplitParser {
            onRead: (line) => {
                if (line.includes("'Strength'"))
                    root._parseApStrength(line);
            }
        }

        onExited: {
            if (root._activeApPath.length > 0)
                apStrengthRestartTimer.start();
        }
    }

    Timer {
        id: apStrengthRestartTimer
        interval: 2000
        onTriggered: {
            if (root._activeApPath.length > 0)
                root._startApStrengthMonitor(root._activeApPath);
        }
    }

    // -----------------------------------------------------------------------
    // TIER 2 – Wi-Fi list (on-demand)
    // -----------------------------------------------------------------------
    // Uses a dedicated Process (not Command) because we need the full streamed
    // stdout before parsing; Command could be used here but a named Process
    // lets us expose the `scanning` property cleanly via wifiListProc.running.

    Process {
        id: wifiListProc

        command: [
            "nmcli", "-t",
            "-f", "SSID,SIGNAL,SECURITY,BARS,ACTIVE",
            "dev", "wifi", "list"
        ]
        running: false

        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })

        stdout: StdioCollector {
            onStreamFinished: root._availableWifi = root._parseWifiList(text)
        }
    }

    // -----------------------------------------------------------------------
    // TIER 2 – Wi-Fi rescan trigger
    // -----------------------------------------------------------------------

    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        running: false
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        onExited: root.refreshWifiList()  // qmllint disable signal-handler-parameters
    }

    // -----------------------------------------------------------------------
    // TIER 2 – Saved / known connection profiles
    // -----------------------------------------------------------------------

    Process {
        id: knownProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE,UUID", "connection", "show"]
        running: false
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: root._knownNetworks = root._parseKnownNetworks(text)
        }
    }

    // -----------------------------------------------------------------------
    // TIER 2 – Active connection detail query (SSID + signal via nmcli)
    // -----------------------------------------------------------------------

    Process {
        id: activeDetailProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]
        running: false
        environment: ({ LANG: "C.UTF-8", LC_ALL: "C.UTF-8" })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "\u0000";
                for (const rawLine of text.trim().split("\n")) {
                    if (!rawLine) continue;
                    const line  = rawLine.replace(/\\:/g, PLACEHOLDER);
                    const parts = line.split(":");
                    const active = (parts[0] ?? "").replace(/\u0000/g, ":").trim() === "yes";
                    if (active) {
                        root._activeSsid     = (parts[1] ?? "").replace(/\u0000/g, ":").trim();
                        root._signalStrength = parseInt((parts[2] ?? "0").trim(), 10) || 0;
                        break;
                    }
                }
                // Kick off the DBus AP-path discovery so Tier 1-B can subscribe.
                root._fetchActiveApPath();
            }
        }
    }

    // -----------------------------------------------------------------------
    // Initialisation
    // -----------------------------------------------------------------------

    Component.onCompleted: {
        root._refreshActiveDetails();
        root.refreshKnownNetworks();
        root._queryNetworkingEnabled();
        root._queryWifiEnabled();
    }

    // -----------------------------------------------------------------------
    // Public API – Actions
    // -----------------------------------------------------------------------

    /**
     * Trigger a Wi-Fi rescan followed by a list refresh.
     * Call this when the user opens the Wi-Fi panel.
     */
    function rescanWifi(): void {
        if (!rescanProc.running)
            rescanProc.running = true;
    }

    /**
     * Refresh the cached Wi-Fi list without a full rescan.
     */
    function refreshWifiList(): void {
        if (!wifiListProc.running)
            wifiListProc.running = true;
    }

    /**
     * Refresh the list of saved connection profiles.
     */
    function refreshKnownNetworks(): void {
        if (!knownProc.running)
            knownProc.running = true;
    }

    /**
     * Connect to a new or unseen Wi-Fi network.
     * Emits passwordRequired(ssid) when credentials are missing.
     *
     * @param ssid     - Target SSID
     * @param password - PSK; pass "" for open / saved-profile networks
     * @param callback - Optional function({ success, output, error, exitCode, needsPassword })
     */
    function connectTo(ssid: string, password: string, callback: var): void {
        let cmd = ["nmcli", "dev", "wifi", "connect", ssid];
        if (password && password.length > 0)
            cmd.push("password", password);

        Daemon.execute(cmd, (result) => {
            if (!result.success) {
                if (_detectPasswordRequired(result.error)) {
                    root.passwordRequired(ssid);
                    if (callback)
                        callback({ success: false, output: result.output,
                                   error: result.error,   exitCode: result.exitCode,
                                   needsPassword: true });
                    return;
                }
                root.connectionFailed(ssid);
            }
            if (callback) callback(result);
            Qt.callLater(() => root._refreshActiveDetails(), 1000);
        });
    }

    /**
     * Bring up a saved connection profile by UUID.
     *
     * @param uuid     - UUID from knownNetworks
     * @param callback - Optional result callback
     */
    function up(uuid: string, callback: var): void {
        Daemon.execute(["nmcli", "connection", "up", "uuid", uuid], (result) => {
            if (callback) callback(result);
            Qt.callLater(() => root._refreshActiveDetails(), 1000);
        });
    }

    /**
     * Disconnect the primary Wi-Fi interface.
     * Uses `dev disconnect` to prevent immediate auto-reconnect.
     *
     * @param ifname   - Interface name (e.g. "wlan0"); defaults to "wlan0"
     * @param callback - Optional result callback
     */
    function disconnect(ifname: string, callback: var): void {
        const iface = (ifname && ifname.length > 0) ? ifname : "wlan0";
        Daemon.execute(["nmcli", "dev", "disconnect", iface], (result) => {
            if (callback) callback(result);
            root._activeSsid     = "";
            root._signalStrength = 0;
            root._stopApStrengthMonitor();
        });
    }

    /**
     * Hard-toggle the Wi-Fi radio (flight-mode style).
     *
     * @param on       - true to enable, false to disable
     * @param callback - Optional result callback
     */
    function toggleWifi(on: bool, callback: var): void {
        Daemon.execute(["nmcli", "radio", "wifi", on ? "on" : "off"], (result) => {
            if (result.success) root._wifiEnabled = on;
            if (callback) callback(result);
        });
    }

    /**
     * Enable or disable global nmcli networking.
     *
     * @param on       - true = enable, false = disable
     * @param callback - Optional result callback
     */
    function enableNetworking(on: bool, callback: var): void {
        Daemon.execute(["nmcli", "networking", on ? "on" : "off"], (result) => {
            if (result.success) root._networkingEnabled = on;
            if (callback) callback(result);
        });
    }

    /**
     * Query whether a saved profile is on a metered connection.
     * (Advanced Hook C – Data Metering)
     *
     * @param name     - Connection profile name
     * @param callback - function(isMetered: bool)
     */
    function isMetered(name: string, callback: var): void {
        Daemon.execute(
            ["nmcli", "-f", "connection.metered", "connection", "show", name],
            (result) => {
                if (!result.success || !callback) return;
                // e.g. "connection.metered:  0 (unknown)" / "1 (yes)"
                const val = (result.output.split(":").slice(1).join(":") ?? "").trim();
                callback(val.startsWith("1") || val.toLowerCase().includes("yes"));
            }
        );
    }

    /**
     * Delete a saved connection profile.
     *
     * @param name     - Connection profile name
     * @param callback - Optional result callback
     */
    function forgetNetwork(name: string, callback: var): void {
        Daemon.execute(["nmcli", "connection", "delete", name], (result) => {
            if (result.success)
                Qt.callLater(() => root.refreshKnownNetworks(), 500);
            if (callback) callback(result);
        });
    }

    // -----------------------------------------------------------------------
    // Internal helpers – parsing
    // -----------------------------------------------------------------------

    function _parseConnectivity(line: string): void {
        // 'Connectivity': <uint32 4>
        const match = line.match(/'Connectivity'[^<]*<\s*(?:uint32\s+)?(\d+)\s*>/);
        if (!match) return;
        const val = parseInt(match[1], 10);
        root._connectivity = val;
        // Advanced Hook A: captive-portal detection.
        if (val === 2) {
            root.captivePortalDetected();
            _openCaptivePortal();
        }
    }

    function _parsePrimaryConnectionType(line: string): void {
        // 'PrimaryConnectionType': <'802-3-ethernet'>
        const match = line.match(/'PrimaryConnectionType'[^<]*<\s*'([^']+)'\s*>/);
        if (match) root._primaryConnectionType = match[1];
    }

    function _parseNmState(line: string): void {
        // 'State': <uint32 20>   (20 = disconnected, 70 = connected globally)
        const match = line.match(/'State'[^<]*<\s*(?:uint32\s+)?(\d+)\s*>/);
        if (!match) return;
        if (parseInt(match[1], 10) === 20) {
            root._activeSsid     = "";
            root._signalStrength = 0;
            root._stopApStrengthMonitor();
        }
    }

    function _parseApStrength(line: string): void {
        // 'Strength': <byte 0x4c>  or  <byte 76>
        const matchHex = line.match(/'Strength'[^<]*<\s*byte\s+0x([0-9a-fA-F]+)\s*>/);
        const matchDec = line.match(/'Strength'[^<]*<\s*byte\s+(\d+)\s*>/);
        if (matchHex)      root._signalStrength = parseInt(matchHex[1], 16);
        else if (matchDec) root._signalStrength = parseInt(matchDec[1], 10);
    }

    function _parseWifiList(text: string): var {
        if (!text || text.length === 0) return [];
        const PLACEHOLDER = "\u0000";
        const list = [];
        const seen = new Set();
        for (const rawLine of text.trim().split("\n")) {
            if (!rawLine) continue;
            const line  = rawLine.replace(/\\:/g, PLACEHOLDER);
            const parts = line.split(":");
            const ssid  = (parts[0] ?? "").replace(/\u0000/g, ":").trim();
            if (!ssid || seen.has(ssid)) continue;
            seen.add(ssid);
            list.push({
                ssid:     ssid,
                strength: parseInt((parts[1] ?? "0").trim(), 10) || 0,
                security: (parts[2] ?? "").replace(/\u0000/g, ":").trim(),
                bars:     (parts[3] ?? "").replace(/\u0000/g, ":").trim(),
                active:   (parts[4] ?? "").trim() === "yes"
            });
        }
        list.sort((a, b) => {
            if (a.active !== b.active) return a.active ? -1 : 1;
            return b.strength - a.strength;
        });
        return list;
    }

    function _parseKnownNetworks(text: string): var {
        if (!text || text.length === 0) return [];
        const PLACEHOLDER = "\u0000";
        const list = [];
        for (const rawLine of text.trim().split("\n")) {
            if (!rawLine) continue;
            const line  = rawLine.replace(/\\:/g, PLACEHOLDER);
            const parts = line.split(":");
            list.push({
                name: (parts[0] ?? "").replace(/\u0000/g, ":").trim(),
                type: (parts[1] ?? "").replace(/\u0000/g, ":").trim(),
                uuid: (parts[2] ?? "").replace(/\u0000/g, ":").trim()
            });
        }
        return list;
    }

    function _detectPasswordRequired(error: string): bool {
        if (!error || error.length === 0) return false;
        return (
            error.includes("Secrets were required") ||
            error.includes("No secrets provided")   ||
            error.includes("802-11-wireless-security.psk") ||
            error.includes("password for")
        ) && !error.includes("Connection activated") && !error.includes("successfully");
    }

    // -----------------------------------------------------------------------
    // Internal helpers – refresh active details
    // -----------------------------------------------------------------------

    function _refreshActiveDetails(): void {
        if (!activeDetailProc.running)
            activeDetailProc.running = true;
    }

    function _queryNetworkingEnabled(): void {
        Daemon.execute(["nmcli", "networking"], (result) => {
            if (result.success)
                root._networkingEnabled = result.output.trim() === "enabled";
        });
    }

    function _queryWifiEnabled(): void {
        Daemon.execute(["nmcli", "radio", "wifi"], (result) => {
            if (result.success)
                root._wifiEnabled = result.output.trim() === "enabled";
        });
    }

    // -----------------------------------------------------------------------
    // Internal helpers – AP DBus path discovery (for signal-strength monitor)
    // -----------------------------------------------------------------------

    function _fetchActiveApPath(): void {
        Daemon.execute(
            ["gdbus", "call",
             "--system",
             "--dest",        "org.freedesktop.NetworkManager",
             "--object-path", "/org/freedesktop/NetworkManager",
             "--method",      "org.freedesktop.NetworkManager.GetDevices"],
            (result) => {
                if (!result.success) return;
                const paths = [];
                const re = /objectpath '([^']+)'/g;
                let m;
                while ((m = re.exec(result.output)) !== null)
                    paths.push(m[1]);
                root._probeDevicesForApPath(paths, 0);
            }
        );
    }

    function _probeDevicesForApPath(paths: var, index: int): void {
        if (index >= paths.length) return;
        const path = paths[index];
        Daemon.execute(
            ["gdbus", "get",
             "--system",
             "--dest",        "org.freedesktop.NetworkManager",
             "--object-path", path,
             "--property",    "org.freedesktop.NetworkManager.Device:DeviceType"],
            (result) => {
                // DeviceType 2 = Wi-Fi
                if (result.success && result.output.includes("uint32 2")) {
                    Daemon.execute(
                        ["gdbus", "get",
                         "--system",
                         "--dest",        "org.freedesktop.NetworkManager",
                         "--object-path", path,
                         "--property",    "org.freedesktop.NetworkManager.Device.Wireless:ActiveAccessPoint"],
                        (apResult) => {
                            if (!apResult.success) return;
                            const apMatch = apResult.output.match(/objectpath '([^']+)'/);
                            if (apMatch && apMatch[1] !== "/" && apMatch[1].length > 1)
                                root._startApStrengthMonitor(apMatch[1]);
                        }
                    );
                } else {
                    root._probeDevicesForApPath(paths, index + 1);
                }
            }
        );
    }

    function _startApStrengthMonitor(apPath: string): void {
        root._activeApPath        = apPath;
        apStrengthMonitor.running = false;
        apStrengthMonitor.command = [
            "gdbus", "monitor",
            "--system",
            "--dest",        "org.freedesktop.NetworkManager",
            "--object-path", apPath
        ];
        apStrengthMonitor.running = true;
    }

    function _stopApStrengthMonitor(): void {
        root._activeApPath        = "";
        apStrengthMonitor.running = false;
    }

    // -----------------------------------------------------------------------
    // Internal helper – captive portal (Advanced Hook A)
    // -----------------------------------------------------------------------

    function _openCaptivePortal(): void {
        Daemon.execute(
            ["xdg-open", "http://nmcheck.gnome.org/check_network_status.txt"],
            (result) => console.log(lc, "Captive portal launched (exit " + result.exitCode + ")")
        );
    }

    // -----------------------------------------------------------------------
    // Logging
    // -----------------------------------------------------------------------

    LoggingCategory {
        id: lc
        name: "caelestia.qml.services.networking"
        defaultLogLevel: LoggingCategory.Info
    }
}
