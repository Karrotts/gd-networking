extends Node

# Server side signals
## Emitted when a peer joins the server. Contains the Id of the peer that connected.
signal on_peer_connected(id: int)

## Emitted when a peer disconnects from the server. Contains the Id of the peer that disconnected
signal on_peer_disconnected(id: int)

## Emitted when the server receives a packet. Contains the Id and the packet data.
signal on_server_packet(id: int, data: PackedByteArray)

# Client side signals
## Emitted when the client connects to the server
signal on_connected_to_server()

## Emitted when the client disconnects from the server
signal on_disconnected_from_server()

## Emitted when the client receives a packet. Contains the packet data.
signal on_client_packet(data: PackedByteArray)

# Server vars
var available_peer_ids = range(255, -1, -1) # Max 255 Ids
var client_peers: Dictionary[int, ENetPacketPeer]

# Client vars
var server_peer: ENetPacketPeer

# General
var connection: ENetConnection
var is_server: bool
var packet_registry: PacketRegistry = PacketRegistry.new()
var packet_forwarder: PacketForwarder= PacketForwarder.new()
var client_manager: ClientManager

func _enter_tree() -> void:
	client_manager = ClientManager.new()


func _process(_delta: float) -> void:
	if connection == null: return
	_handle_events()


func _handle_events() -> void:
	var packet_event := connection.service()
	var event_type: ENetConnection.EventType = packet_event[0]
	while event_type != ENetConnection.EVENT_NONE:
		var peer: ENetPacketPeer = packet_event[1]
		
		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("Packet resulted in an error...")
			ENetConnection.EVENT_CONNECT:
				if is_server:
					_peer_connected(peer)
				else:
					_connected_to_server()
			ENetConnection.EVENT_DISCONNECT:
				if is_server:
					_peer_disconnected(peer)
				else:
					_disconnected_to_server()
					return
			ENetConnection.EVENT_RECEIVE:
				var data: PackedByteArray = peer.get_packet()
				if is_server:
					on_server_packet.emit(peer.get_meta("id"), data)
					packet_forwarder.handle_server_packet(peer.get_meta("id"), data)
				else:
					on_client_packet.emit(data)
					packet_forwarder.handle_client_packet(data)
		# Get next packet
		packet_event = connection.service()
		event_type = packet_event[0]
		

func start_server(address: String = "127.0.0.1", port: int = 7000) -> void:
	connection = ENetConnection.new()
	var error = connection.create_host_bound(address, port)
	if error != OK:
		push_error("Unable to create server on [%s:%d]" % [address, port])
		connection = null
		return
	print("Server started on [%s:%d]" % [address, port])
	is_server = true
	

func start_client(address: String = "127.0.0.1", port: int = 7000) -> void:
	connection = ENetConnection.new()
	var error = connection.create_host(1)
	if error != OK:
		push_error("Unable to create client")
		connection = null
		return
	server_peer = connection.connect_to_host(address, port)


func disconnect_client() -> void:
	if is_server: return
	server_peer.peer_disconnect()
	client_manager.handle_disconnect()
	

func _peer_connected(peer: ENetPacketPeer) -> void:
	var id: int = available_peer_ids.pop_back()
	peer.set_meta("id", id)
	client_peers[id] = peer
	on_peer_connected.emit(id)
	print("Peer connected [%d]" % id)
	IdAssignmentPacket.create(id, client_peers.keys()).broadcast(connection)


func _peer_disconnected(peer: ENetPacketPeer) -> void:
	var id: int = peer.get_meta("id")
	available_peer_ids.push_back(id)
	client_peers.erase(id)
	on_peer_disconnected.emit(id)
	print("Peer disconnected [%d]" % id)


func _connected_to_server() -> void:
	print("Connected to server")
	on_connected_to_server.emit()

	
func _disconnected_to_server() -> void:
	print("Disconnected from server")
	on_disconnected_from_server.emit()
	connection = null
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and connection != null:
		disconnect_client()
