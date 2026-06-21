# GD-Networking

A low-level, ENet-based client/server networking framework for **Godot 4.7+**, written entirely in GDScript. It sits *below* Godot's high-level `MultiplayerAPI` and gives you direct control over the connection, the binary packet format, and authentication — at the cost of having to wire up your own replication and RPCs.

It ships as a ready-to-run demo project (`project.godot`) containing a working server/client scene and a server browser, but the actual library lives entirely inside the `networking/` folder and is meant to be dropped into your own Godot project.

## What this project accomplishes

- **Raw ENet client/server stack** — wraps `ENetConnection` / `ENetPacketPeer` directly (not `SceneMultiplayer`), polled once per frame from a single autoload.
- **Typed binary packet protocol** — every packet is a GDScript class that knows how to serialize and deserialize itself into a `PackedByteArray`, registered against a single-byte packet ID.
- **Connection handshake & peer ID assignment** — when a peer connects, the server hands out a small integer ID and tells every client about every other connected ID.
- **Pluggable identity/authentication layer** — a `IdentityProvider` interface lets you decide how clients prove who they are during the handshake, with a working reference implementation (`BasicIdentityProvider`) that persists a generated client ID + secret to disk.
- **Built-in latency measurement** — a ping packet the server simply echoes back.
- **"Ping without joining" server info protocol** — a client can ask a server for its name/description/player count/ping *without* completing a full handshake, which powers the included **server browser** UI.

## Requirements

- Godot **4.7** or later (uses typed `Dictionary[int, Script]`, `Array[int]`, and other Godot 4.4+/4.7 GDScript features).
- No external addons — only built-in `ENetConnection`, `ENetPacketPeer`, and `StreamPeerBuffer`.

## Installation

1. Copy the `networking/` directory into your Godot project (e.g. `res://networking/`).
2. Register the autoload so the network stack is processed every frame:
    - **Project → Project Settings → Autoload**
    - Path: `res://networking/network-handler.gd`
    - Node Name: `NetworkHandler`
3. (Optional) Run with the `--server` command-line flag to auto-start a dedicated, headless server on launch (see `network-handler.gd`).

Everything below assumes the autoload is named `NetworkHandler`, exactly as it is in this demo project.

## Project structure

```
networking/
├── network-handler.gd          # Autoload singleton: owns + drives the client/server managers
├── network-settings.gd         # Base connection settings (address, port, versions)
├── codeable.gd                 # Base class for anything that can encode()/decode() itself
│
├── client/
│   └── client-manager.gd       # ENet client: connect, send, receive, handshake, ping
│
├── server/
│   ├── server-manager.gd       # ENet server: bind, accept peers, broadcast, receive
│   └── server-settings.gd      # Server config (name, description, capacity), persisted to disk
│
├── identity/
│   ├── identity-provider.gd        # Pluggable auth interface
│   ├── identity-authentication.gd  # Small auth result struct
│   └── builtin/
│       ├── basic-identity.gd            # Codeable: client_id + secret
│       └── basic-identity-provider.gd   # Reference auth implementation (file-persisted)
│
└── packet/
    ├── packet-info.gd          # Base packet class (adds the leading type byte)
    ├── generic-packet-info.gd  # PacketInfo + helper to decode an embedded Codeable payload
    ├── packet-registry.gd      # Maps packet type byte -> packet class, builds packets from bytes
    └── types/
        ├── id-assignment-packet.gd           # type 0
        ├── ping-packet.gd                    # type 1
        ├── handshake-packet.gd               # type 2
        ├── identity-authentication-packet.gd # type 3
        ├── server-info-request-packet.gd     # type 4
        └── server-info-packet.gd             # type 5

root.gd / root.tscn                  # Minimal demo: start server, start client, show ping
server-browser.gd / .tscn            # Demo: query multiple servers for info without joining
server_item_panel.gd / .tscn         # UI row used by the server browser
```

## Core concepts

### `NetworkHandler` (autoload)

The single entry point into the library. It owns one `PacketRegistry`, one `ClientManager`, and one `ServerManager`, and calls `process()` on both every frame from `_process()`. On launch it also checks `OS.get_cmdline_args()` for `--server` and auto-starts a server if present — handy for dedicated server builds. On the engine's `NOTIFICATION_WM_CLOSE_REQUEST`, it cleanly disconnects the client.

```gdscript
NetworkHandler.client_manager   # ClientManager
NetworkHandler.server_manager   # ServerManager
NetworkHandler.set_identity_provider(my_provider)  # applies to both client + server
```

### `Codeable` — the serialization base class

Everything that goes over the wire (packets, identity payloads, etc.) extends `Codeable` and implements:

```gdscript
func encode() -> PackedByteArray
func decode(packet: PackedByteArray) -> void
```

`Codeable` provides two small helpers (`get_encode_buffer()` / `get_decode_buffer()`) that wrap a `StreamPeerBuffer`, which is what the binary format is actually built on (`put_8`, `put_string`, `put_data`, etc.).

### `PacketInfo` / `GenericPacketInfo`

`PacketInfo extends Codeable` and adds a `type: int` field that is always written as the **first byte** of the encoded packet. Every concrete packet class overrides `get_packet_type()` (static) to declare its own ID, and overrides `get_encode_buffer()` / `get_decode_buffer()` to add its own fields on top of the base class's (`super.get_encode_buffer()` first, *then* your fields).

`GenericPacketInfo extends PacketInfo` additionally exposes `convert_generic(generic: Codeable) -> Codeable`, used when a packet carries an *embedded* payload of unknown concrete type (for example, a `HandshakePacket` carries raw identity bytes whose actual shape depends on whichever `IdentityProvider` you're using).

### `PacketRegistry`

A simple `Dictionary[int, Script]` mapping a packet-type byte to a packet class.

```gdscript
func register(id: int, packet_info: Script) -> void
func create_packet(data: PackedByteArray) -> PacketInfo   # reads byte 0, instantiates + decodes
```

The six built-in packet types are registered automatically when a `PacketRegistry` is constructed. **Packet IDs are a single byte**, so you have up to 256 total packet types, and **IDs 0–5 are reserved** by the built-ins below.

| ID | Class | Sent by | Purpose |
|----|-------|---------|---------|
| 0 | `IdAssignmentPacket` | Server → all clients (broadcast) | Assigns a new peer's ID, lists every currently-connected peer ID |
| 1 | `PingPacket` | Client → Server → Client (echo) | Round-trip latency measurement |
| 2 | `HandshakePacket` | Client → Server | Game/packet version + embedded identity payload |
| 3 | `IdentityAuthenticationPacket` | Server → Client | Auth success flag + embedded identity-provider response payload |
| 4 | `ServerInfoRequestPacket` | Client → Server | "Tell me about yourself" probe (used to avoid a full join) |
| 5 | `ServerInfoPacket` | Server → Client | Server name/description/capacity/current player count + timestamp |

Custom packet types should start at ID `6` or above.

### `ClientManager`

Wraps a single outgoing `ENetConnection`. Key methods:

```gdscript
client_manager.start_client(settings: NetworkSettings, attempt_connect: bool = true)
client_manager.send_to_server(bytes: PackedByteArray, flag := ENetPacketPeer.FLAG_RELIABLE, channel := 0)
client_manager.send_ping()
client_manager.handle_disconnect()
client_manager.is_authority(id: int) -> bool   # is `id` this client's own assigned ID?
```

`process()` must be called every frame (the autoload already does this) to pump ENet events. Internally, the manager:

1. On `IdAssignmentPacket`, records `client_id` / `client_peer_ids`.
2. If `attempt_connect` is `true`, immediately replies with a `HandshakePacket` containing the active `IdentityProvider`'s handshake data — this is the normal "join the game" path.
3. If `attempt_connect` is `false`, it instead sends a `ServerInfoRequestPacket` and auto-disconnects once the `ServerInfoPacket` reply arrives — this is the lightweight "just tell me your server info" path used by the server browser.
4. `PingPacket` round trips are handled internally and surfaced via `on_ping(ping_ms)`; they are **not** forwarded to `on_client_packet`.

Signals: `on_client_id_assignment`, `on_connected_to_server`, `on_disconnected_from_server`, `on_client_packet(packet)`, `on_ping(ping_ms)`.

### `ServerManager`

Wraps a bound `ENetConnection`. Key methods:

```gdscript
server_manager.start_server(settings: ServerSettings)
server_manager.broadcast(bytes: PackedByteArray, flag := ENetPacketPeer.FLAG_RELIABLE, channel := 0)
server_manager.send_to_peer(peer_id: int, bytes: PackedByteArray, flag := ..., channel := 0)
```

Internally, on every connection it pops the next free ID from a pool (`range(255, -1, -1)`, so **peer IDs are also single bytes — max 255 concurrent peers**), broadcasts an `IdAssignmentPacket`, and tracks the `ENetPacketPeer` by that ID. `PingPacket`, `HandshakePacket` (→ runs `IdentityProvider.authenticate`), and `ServerInfoRequestPacket` (→ replies with `ServerInfoPacket`) are all handled internally.

Signals: `on_peer_connected(id)`, `on_peer_disconnected(id)`, `on_server_packet(id, raw_bytes)` (fires for **every** received packet, decoded or not), `on_server_packet_info(id, packet)` (fires for decoded, non-internal packets — this is where your game logic should hook in).

### Identity / authentication

`IdentityProvider` is the extension point:

```gdscript
func get_client_decode() -> Codeable          # how the server decodes a client's handshake identity
func get_authentication_decode() -> Codeable  # how the client decodes the server's auth response
func client_handshake_data() -> Codeable      # what the client sends to identify itself
func authenticate(data: Codeable) -> IdentityAuthenticationPacket   # server-side decision
func handle_authentication_response(identity, client_manager) -> void  # client-side reaction
```

The bundled `BasicIdentityProvider` is a working reference implementation:

- **Client side**: looks up a saved `client_id`/`secret` for the target `address:port` in `user://server_user_info.json`. If none exists, it sends an empty identity and lets the server mint a new one.
- **Server side**: stores known `client_id` → `{ secret, first_seen, last_seen }` records in `user://server/server_users.json`. An empty identity is always accepted and gets assigned a fresh UUID-style ID and a random 32-byte hex secret; a returning identity is checked against the stored secret.
- On the client, `handle_authentication_response` persists whatever identity the server confirmed and disconnects automatically if `success` was `false`.

Apply a provider to both the client and server managers at once via:

```gdscript
NetworkHandler.set_identity_provider(BasicIdentityProvider.new())
```

### Settings

- `NetworkSettings` — base: `game_version`, `packet_version`, `address` (default `127.0.0.1`), `port` (default `7000`). Used as-is by clients.
- `ServerSettings extends NetworkSettings` — adds `server_name`, `server_description`, `max_allowed_players`, and `game_version_must_match` / `packet_version_must_match` flags. Automatically loads/saves itself as JSON to `user://server/server_config.json` so a dedicated server keeps its identity across restarts.

## Usage

### 1. Start a server

```gdscript
NetworkHandler.server_manager.start_server(ServerSettings.new())
```

### 2. Connect a client

```gdscript
NetworkHandler.set_identity_provider(BasicIdentityProvider.new())
NetworkHandler.client_manager.start_client(NetworkSettings.new())

NetworkHandler.client_manager.on_connected_to_server.connect(func():
    print("Connected!")
)
NetworkHandler.client_manager.on_client_id_assignment.connect(func(packet: IdAssignmentPacket):
    print("My ID is ", packet.id, " other peers: ", packet.remote_ids)
)
```

### 3. Measure ping

```gdscript
func _process(_delta: float) -> void:
    NetworkHandler.client_manager.send_ping()

func _ready() -> void:
    NetworkHandler.client_manager.on_ping.connect(func(ping_ms: int):
        $Ping.text = "Ping: %d ms" % ping_ms
    )
```

### 4. Define and register a custom packet

```gdscript
# move-packet.gd
class_name MovePacket extends PacketInfo

var x: float
var y: float

func _init() -> void:
    type = get_packet_type()

func get_encode_buffer() -> StreamPeerBuffer:
    var buffer := super.get_encode_buffer()
    buffer.put_float(x)
    buffer.put_float(y)
    return buffer

func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
    var buffer := super.get_decode_buffer(packet)
    x = buffer.get_float()
    y = buffer.get_float()
    return buffer

static func get_packet_type() -> int:
    return 6   # first free ID after the built-ins (0-5)
```

```gdscript
# Register it once, e.g. right after NetworkHandler is ready:
NetworkHandler.client_manager.packet_registry.register(MovePacket.get_packet_type(), MovePacket)
```

### 5. Send and receive custom packets

```gdscript
# Client -> server
var packet := MovePacket.new()
packet.x = 12.0
packet.y = 4.0
NetworkHandler.client_manager.send_to_server(packet.encode())

# Server: broadcast or target a peer
NetworkHandler.server_manager.broadcast(packet.encode())
NetworkHandler.server_manager.send_to_peer(peer_id, packet.encode())

# Server: react to incoming packets
NetworkHandler.server_manager.on_server_packet_info.connect(func(id: int, packet: PacketInfo):
    if packet is MovePacket:
        print("Peer %d moved to (%f, %f)" % [id, packet.x, packet.y])
)

# Client: react to incoming packets
NetworkHandler.client_manager.on_client_packet.connect(func(packet: PacketInfo):
    if packet is MovePacket:
        print("Server says move to (%f, %f)" % [packet.x, packet.y])
)
```

### 6. Check authority over an ID

```gdscript
if NetworkHandler.client_manager.is_authority(some_id):
    # this peer is "us"
    pass
```

### 7. Query a server without joining (server browser pattern)

Passing `false` as the second argument to `start_client` skips the handshake/auth flow entirely — the client only asks for `ServerInfoPacket` and then disconnects, which is exactly what the included `server-browser.gd` / `server_item_panel.gd` demo does for each server a user adds to their list:

```gdscript
var settings := NetworkSettings.new()
settings.address = "127.0.0.1"
settings.port = 7000
NetworkHandler.client_manager.start_client(settings, false)
```

## Running the included demo

1. Open the project in Godot 4.7+.
2. Run the main scene (`root.tscn`): click **Start Server**, then **Start Client** to connect locally; the ping label updates every frame once connected.
3. Or run the project with the `--server` launch argument to boot directly into a headless/dedicated server.
4. `server_browser.tscn` shows a standalone screen where you can type in an address/port, add it to a list, and see live name/description/player-count/ping info pulled from each server without ever joining it.

## Known limitations to be aware of

- **255 peer cap** — peer and packet-type IDs are single bytes, so a server tops out at 255 simultaneously connected clients, and the registry tops out at 256 packet types (6 reserved).
- **No automatic replication/RPC layer** — this library only gets bytes from A to B reliably; you still own all game-state synchronization, interpolation, and authority logic on top of it.
- **`game_version_must_match` / `packet_version_must_match`** exist on `ServerSettings` but the bundled `HandshakePacket`/auth flow doesn't currently enforce them — add that check yourself in a custom `IdentityProvider.authenticate()` if you need it.
- **`BasicIdentityProvider` is a reference implementation**, not hardened security — secrets are stored in plaintext JSON under `user://`, with no transport encryption (ENet packets are sent as-is).