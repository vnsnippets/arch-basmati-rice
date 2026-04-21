# Services

## Network Service 

A reactive, event-driven singleton for monitoring and controlling network connectivity through NetworkManager.

It follows a **Two-Tier architecture**:
- Tier 1: A persistent DBus stream provides instant change notifications
- Tier 2: On-demand `nmcli` and `gdbus` calls handle data-heavy queries and actions.

> All Tier-2 one-shot commands are routed through the `Daemon.qml` singleton so process lifetimes are managed in one place.

---

### Dependencies

| Dependency | Purpose |
|---|---|
| `gdbus` (part of `glib2`) | Persistent monitors and One-shot property gets |
| `nmcli` (part of `networkmanager`) | Scanning, connecting, status queries, radio control |
| `xdg-open` | Opening the captive-portal browser |

Import it via:

```qml
import qs.Services

// Access the singleton directly:
Networking.activeSsid
Networking.connectTo("MySSID", "password", callback)
```

---

### Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                     Networking.qml                       │
│                                                          │
│  TIER 1 – Persistent Streaming (bare Process objects)    │
│  ┌──────────────────┐   ┌────────────────────────────┐   │
│  │  globalMonitor   │   │    apStrengthMonitor        │  │
│  │  gdbus monitor   │   │    gdbus monitor (per-AP)   │  │
│  │  /NM root path   │   │    dynamic object-path      │  │
│  └────────┬─────────┘   └───────────┬────────────────┘   │
│           │ events                  │ Strength byte      │
│           ▼                         ▼                    │
│     parse + update             _signalStrength           │
│     reactive properties                                  │
│                                                          │
│  TIER 2 – On-Demand (via Command.execute or named Proc)  │
│  ┌────────────┐ ┌───────────┐ ┌────────────────────┐     │
│  │wifiListProc│ │rescanProc │ │  activeDetailProc   │    │
│  │nmcli list  │ │nmcli      │ │  nmcli dev wifi     │    │
│  └────────────┘ │--rescan   │ └────────────────────┘     │
│                 └───────────┘                            │
│  All public action functions → Command.execute()         │
└──────────────────────────────────────────────────────────┘
```

---

### Reactive Properties (Subscribe, don't poll)

These update automatically whenever NetworkManager emits a DBus signal.   
Bind to them directly in your UI — no timers needed.

| Property | Type | Description |
|---|---|---|
| `isRunning` | `bool` | `true` while the `gdbus monitor` is receiving output from NM |
| `connectivity` | `int` | NM global connectivity level: `0` unknown · `1` none · `2` captive portal · `3` limited · `4` full |
| `activeSsid` | `string` | SSID of the currently connected Wi-Fi AP, or `""` when wired / offline |
| `signalStrength` | `int` | Signal strength of the active AP (0–100), pushed by the per-AP DBus monitor |
| `isWired` | `bool` | `true` when `PrimaryConnectionType` is `802-3-ethernet` |
| `wifiEnabled` | `bool` | `true` when the Wi-Fi radio is on |
| `networkingEnabled` | `bool` | `true` when global `nmcli networking` is enabled |

#### Typical UI binding

```qml
Text {
    text: Networking.activeSsid !== ""
        ? `${Networking.activeSsid} (${Networking.signalStrength}%)`
        : Networking.isWired ? "Wired" : "Offline"
    color: Networking.connectivity >= 4 ? "green" : "red"
}
```

#### Connectivity value reference

| Value | Meaning |
|---|---|
| `0` | Unknown |
| `1` | No connectivity (offline) |
| `2` | Captive portal — login required |
| `3` | Limited — local network only, no internet |
| `4` | Full internet access |

---

### On-Demand Properties (need explicit refresh)

These are populated only when you call their corresponding refresh function.
Call them when your UI panel opens, not on a timer.

| Property | Type | Populated by | Each entry shape |
|---|---|---|---|
| `availableWifi` | `var[]` | `rescanWifi()` / `refreshWifiList()` | `{ ssid, strength, security, bars, active }` |
| `knownNetworks` | `var[]` | `refreshKnownNetworks()` | `{ name, type, uuid }` |
| `scanning` | `bool` | Automatically `true` while any scan is in-flight | — |

---

### Signals

Subscribe to these for events that need UI feedback.

| Signal | Arguments | When emitted |
|---|---|---|
| `captivePortalDetected()` | — | `connectivity` becomes `2`; `xdg-open` is also launched automatically |
| `connectionFailed(ssid)` | `string ssid` | A `connectTo` attempt exits non-zero and is not a password issue |
| `passwordRequired(ssid)` | `string ssid` | NM rejects the connection because no / wrong PSK was supplied |

#### Example

```qml
Connections {
    target: Networking

    function onPasswordRequired(ssid) {
        passwordPrompt.ssid = ssid;
        passwordPrompt.visible = true;
    }

    function onConnectionFailed(ssid) {
        notificationBanner.show(`Failed to connect to ${ssid}`);
    }

    function onCaptivePortalDetected() {
        notificationBanner.show("Login required — browser opened");
    }
}
```

---

### Public Functions

#### Wi-Fi Scanning

```qml
// Full rescan (slow, triggers radio scan) → then calls refreshWifiList()
Networking.rescanWifi()

// Fast list refresh from NM cache (no radio activity)
Networking.refreshWifiList()

// Refresh the saved-profiles list
Networking.refreshKnownNetworks()
```

Call `rescanWifi()` when the panel opens. Bind the list to `Networking.availableWifi`.

---

#### Connecting

```qml
// New or open network
Networking.connectTo("MySSID", "", (result) => {
    console.log(result.success, result.output);
});

// Secured network with password
Networking.connectTo("MySSID", "hunter2", (result) => {
    if (!result.success && result.needsPassword) {
        // passwordRequired signal was also emitted
    }
});

// Known / saved profile by UUID (from knownNetworks)
Networking.up("a1b2c3-uuid", (result) => { ... });
```

**Password flow:** If `connectTo` is called with an empty password on a
secured network, NM will fail and the `passwordRequired(ssid)` signal fires.
Show a password prompt in response and call `connectTo` again with the
credential.

---

#### Disconnecting

```qml
// Disconnect a specific interface (prevents auto-reconnect)
Networking.disconnect("wlan0", (result) => { ... });

// Omit ifname to default to "wlan0"
Networking.disconnect("", null);
```

Uses `nmcli dev disconnect` (not `connection down`) so NM does not
immediately re-establish the connection.

---

#### Radio & Networking Toggles

```qml
// Hard Wi-Fi radio toggle (flight-mode style)
Networking.toggleWifi(false, (result) => { ... }); // off
Networking.toggleWifi(true,  null);                 // on, no callback

// Enable / disable global networking (controls auto-retry on resume)
Networking.enableNetworking(false, null); // stops reconnect attempts
Networking.enableNetworking(true,  null);
```

---

#### Advanced Queries

```qml
// Check if a profile is on a metered (mobile hotspot) connection
Networking.isMetered("Hotspot Profile", (metered) => {
    if (metered) warningBanner.show("Metered connection — updates paused");
});

// Delete a saved profile
Networking.forgetNetwork("OldNetwork", (result) => {
    console.log(result.success);
});
```

---

### Internal Processes at a Glance

> These run automatically. You do not need to start or stop them.

| ID | Command | Lifecycle | Purpose |
|---|---|---|---|
| `globalMonitor` | `gdbus monitor … /org/freedesktop/NetworkManager` | Always running, auto-restarts after 3 s | Tier 1 event source for connectivity, state, and connection changes |
| `apStrengthMonitor` | `gdbus monitor … <AP object path>` | Starts when an AP becomes active; stops on disconnect | Tier 1-B: pushes `signalStrength` updates without polling |
| `wifiListProc` | `nmcli -t -f SSID,SIGNAL,SECURITY,BARS,ACTIVE dev wifi list` | On-demand (triggered by `refreshWifiList`) | Populates `availableWifi` |
| `rescanProc` | `nmcli dev wifi list --rescan yes` | On-demand (triggered by `rescanWifi`) | Forces a radio scan, then calls `refreshWifiList` on exit |
| `knownProc` | `nmcli -t -f NAME,TYPE,UUID connection show` | On-demand (triggered by `refreshKnownNetworks`) | Populates `knownNetworks` |
| `activeDetailProc` | `nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi` | Triggered by Tier 1 events and on startup | Updates `activeSsid` + `signalStrength`; kicks off AP-path discovery |

All **action** calls (`connectTo`, `up`, `disconnect`, `toggleWifi`, etc.) are
routed through `Command.execute()` and are tracked in `Command.processes`.

---

### Advanced Hooks

#### A — Captive Portal Detection
When `connectivity` transitions to `2`, the service automatically:
1. Emits `captivePortalDetected()`
2. Calls `xdg-open http://nmcheck.gnome.org/check_network_status.txt`

Subscribe to the signal if you want to show an in-shell notification instead
of (or in addition to) the browser.

#### B — Reactive Signal Strength
On every active-connection change, the service:
1. Queries `GetDevices` via `gdbus call`
2. Probes each device's `DeviceType` to find the Wi-Fi adapter
3. Reads `ActiveAccessPoint` object path
4. Starts `apStrengthMonitor` on that path

`signalStrength` is then updated by the DBus `Strength` byte property as the
driver reports it — no polling at all.

#### C — Metered Connections
`isMetered(name, callback)` calls:
```
nmcli -f connection.metered connection show <name>
```
Returns `true` when the field is `1 (yes)`. Use this to gate large downloads
or OS updates.

#### D — Wired / Wireless Switching (Phase 4)
`isWired` is a computed binding on `_primaryConnectionType`. When NM emits a
`PrimaryConnectionType` change to `"802-3-ethernet"`, `isWired` flips
immediately. Use it to swap signal-bar icons for an Ethernet icon in your bar.

```qml
icon: Networking.isWired ? "" : strengthIcon(Networking.signalStrength)
```

***

## NMCLI Service

The `NMCLI.qml` service is a singleton providing a comprehensive interface for managing network connections via the `nmcli` command-line tool. It supports both wireless (Wi-Fi) and wired (Ethernet) interfaces, connection monitoring, and network scanning.

### Variables for Client Use

These properties are intended for external use by components consuming this service.

| Variable | Type | Description |
| :--- | :--- | :--- |
| `deviceStatus` | `var` | Raw status information for network devices. |
| `wirelessInterfaces` | `var` | List of detected wireless network interfaces. |
| `ethernetInterfaces` | `var` | List of detected ethernet network interfaces. |
| `isConnected` | `bool` | Indicates if any network connection is currently active. |
| `activeInterface` | `string` | The name of the currently active network interface (e.g., "wlan0"). |
| `activeConnection` | `string` | The name of the currently active network connection. |
| `wifiEnabled` | `bool` | Indicates if the Wi-Fi radio is enabled. |
| `scanning` | `readonly bool` | True if a Wi-Fi network scan is currently in progress. |
| `networks` | `readonly list<AccessPoint>` | List of available Wi-Fi access points. Each `AccessPoint` object contains: `ssid`, `bssid`, `strength`, `frequency`, `active`, `security`, and `isSecure`. |
| `active` | `readonly AccessPoint` | The currently active Wi-Fi access point, or `null` if not connected to Wi-Fi. |
| `savedConnections` | `list<string>` | List of all saved network connection names. |
| `savedConnectionSsids` | `list<string>` | List of SSIDs for which Wi-Fi connection profiles are saved. |
| `ethernetDevices` | `list<var>` | List of ethernet devices with status and configuration details. |
| `activeEthernet` | `readonly var` | The currently active ethernet device object. |
| `wirelessDeviceDetails` | `var` | Configuration details (IP, gateway, DNS, etc.) for the active wireless interface. |
| `ethernetDeviceDetails` | `var` | Configuration details for the active ethernet interface. |

### Functions

#### Wireless Management

| Function | Arguments | Description |
| :--- | :--- | :--- |
| `rescanWifi()` | None | Triggers a background scan for available Wi-Fi networks. |
| `getNetworks(callback)` | `callback: function(networks)` | Refreshes the list of available networks and returns them via callback. |
| `connectToNetwork(ssid, password, bssid, callback)` | `ssid: string`, `password: string`, `bssid: string`, `callback: function(result)` | Connects to a Wi-Fi network using the provided credentials. |
| `connectToNetworkWithPasswordCheck(ssid, isSecure, callback, bssid)` | `ssid: string`, `isSecure: bool`, `callback: function(result)`, `bssid: string` | Attempts to connect to a network. If `isSecure` is true, it first tries to use a saved password. |
| `forgetNetwork(ssid, callback)` | `ssid: string`, `callback: function(result)` | Deletes the saved connection profile for the specified SSID. |
| `hasSavedProfile(ssid)` | `ssid: string` | Returns `true` if a connection profile exists for the given SSID. |
| `enableWifi(enabled, callback)` | `enabled: bool`, `callback: function(result)` | Enables or disables the Wi-Fi radio. |
| `toggleWifi(callback)` | `callback: function(result)` | Toggles the Wi-Fi radio state. |
| `getWifiStatus(callback)` | `callback: function(enabled)` | Checks if the Wi-Fi radio is enabled. |
| `disconnectFromNetwork()` | None | Disconnects from the current active Wi-Fi network. |

#### Ethernet Management

| Function | Arguments | Description |
| :--- | :--- | :--- |
| `getEthernetInterfaces(callback)` | `callback: function(interfaces)` | Updates the list of ethernet interfaces and devices. |
| `connectEthernet(connectionName, interfaceName, callback)` | `connectionName: string`, `interfaceName: string`, `callback: function(result)` | Connects an ethernet device using a connection profile name or interface name. |
| `disconnectEthernet(connectionName, callback)` | `connectionName: string`, `callback: function(result)` | Disconnects the specified ethernet connection. |
| `getEthernetDeviceDetails(interfaceName, callback)` | `interfaceName: string`, `callback: function(details)` | Updates and returns configuration details for an ethernet interface. |

#### General Device & Status

| Function | Arguments | Description |
| :--- | :--- | :--- |
| `refreshStatus(callback)` | `callback: function(status)` | Updates general connection status, active interface, and active connection name. |
| `getDeviceStatus(callback)` | `callback: function(output)` | Gets the status of all network devices from `nmcli`. |
| `getDeviceDetails(interfaceName, callback)` | `interfaceName: string`, `callback: function(output)` | Gets raw detail output for a specific interface. |
| `getAllInterfaces(callback)` | `callback: function(interfaces)` | Gets a list of all detected network interfaces. |
| `isInterfaceConnected(interfaceName, callback)` | `interfaceName: string`, `callback: function(connected)` | Checks if a specific interface is currently connected. |
| `bringInterfaceUp(interfaceName, callback)` | `interfaceName: string`, `callback: function(result)` | Attempts to connect the specified interface. |
| `bringInterfaceDown(interfaceName, callback)` | `interfaceName: string`, `callback: function(result)` | Disconnects the specified interface. |
| `loadSavedConnections(callback)` | `callback: function(ssids)` | Refreshes the list of saved connection profiles and wireless SSIDs. |

### Processes

The service utilizes several background processes to interact with the system and monitor network changes.

| Process | Description | Lifecycle | Behavior |
| :--- | :--- | :--- | :--- |
| `monitorProc` | Monitors network state changes via `nmcli monitor`. | **Startup** | Runs continuously in the background. If it exits, it is automatically restarted after a 2-second delay. It triggers `refreshOnConnectionChange()` whenever output is detected. |
| `rescanProc` | Performs a manual Wi-Fi scan. | **Triggered** | Started by calling `rescanWifi()`. Runs once and then exits. Triggers `getNetworks()` upon completion. |
| `commandProc` | Used for executing one-off `nmcli` commands. | **Triggered** | Created dynamically via `executeCommand()`. Runs the specified command and returns the result through a callback. |

### Startup Lifecycle

When the service is initialized (`Component.onCompleted`):
1.  **Initial Data Fetch**: It immediately fetches Wi-Fi status, available networks, saved connection profiles, and ethernet interfaces.
2.  **Delayed Detail Update**: After a 2-second delay, it attempts to fetch detailed IP and configuration information for both the active wireless and active ethernet interfaces to ensure all properties are populated correctly once connections are established.
