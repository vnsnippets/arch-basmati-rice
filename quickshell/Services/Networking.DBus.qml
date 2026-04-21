// pragma Singleton
// import QtQuick
// import Quickshell
// import Quickshell.Io

// Scope {
//     id: nmService

//     // Internal State
//     property int _connectivity: 0
//     property string _primaryPath: ""

//     // Exposed Properties
//     readonly property bool isOnline: _connectivity >= 3 // 3 = LOCAL, 4 = FULL
//     readonly property string stateText: getStatusString(_connectivity)

//     // 1. The DBus Monitor Process
//     // This command listens for any property changes in NetworkManager
//     Process {
//         id: dbusMonitor
//         command: [
//             "gdbus", "monitor", 
//             "--system", 
//             "--dest", "org.freedesktop.NetworkManager", 
//             "--object-path", "/org/freedesktop/NetworkManager"
//         ]
//         running: true
//         stdout: StdioCollector {
//             onLineRead: (line) => {
//                 // DBus monitor outputs lines like:
//                 // /org/freedesktop/NetworkManager: org.freedesktop.DBus.Properties.PropertiesChanged ('org.freedesktop.NetworkManager', {'Connectivity': <uint32 4>}, @as [])
                
//                 if (line.includes("Connectivity")) {
//                     parseConnectivity(line);
//                 }
//                 if (line.includes("PrimaryConnection")) {
//                     parsePrimaryConnection(line);
//                 }
//             }
//         }
//     }

//     // 2. The DBus "Getter" (For Initial State)
//     // Since monitor only catches changes, we need one call at startup
//     Process {
//         id: dbusGetInitial
//         command: [
//             "gdbus", "call", "--system",
//             "--dest", "org.freedesktop.NetworkManager",
//             "--object-path", "/org/freedesktop/NetworkManager",
//             "--method", "org.freedesktop.DBus.Properties.Get",
//             "org.freedesktop.NetworkManager", "Connectivity"
//         ]
//         running: true
//         stdout: StdioCollector {
//             onStreamFinished: {
//                 // Output format: (<uint32 4>,)
//                 let match = text.match(/uint32 (\d+)/);
//                 if (match) _connectivity = parseInt(match[1]);
//             }
//         }
//     }

//     // 3. Logic Helpers
//     function parseConnectivity(line) {
//         let match = line.match(/uint32 (\d+)/);
//         if (match) {
//             _connectivity = parseInt(match[1]);
//             console.log("Network connectivity changed to: " + _connectivity);
//         }
//     }

//     function parsePrimaryConnection(line) {
//         // This triggers when you switch from Eth to WiFi
//         // You can then use nmcli to get the name of this specific path
//         refreshActiveConnectionDetails();
//     }

//     function getStatusString(val) {
//         switch(val) {
//             case 4: return "Full Internet";
//             case 3: return "Local Network Only";
//             case 2: return "Portal (Login Required)";
//             case 1: return "Connecting...";
//             default: return "Disconnected";
//         }
//     }

//     function refreshActiveConnectionDetails() {
//         // Trigger your nmcli logic from the previous response here
//     }
// }