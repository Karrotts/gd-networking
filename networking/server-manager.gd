class_name ServerManager

## Emitted when a peer joins the server. Contains the Id of the peer that connected.
signal on_peer_connected(id: int)

## Emitted when a peer disconnects from the server. Contains the Id of the peer that disconnected
signal on_peer_disconnected(id: int)

## Emitted when the server receives a packet. Contains the Id and the packet data.
signal on_server_packet(id: int, data: PackedByteArray)

## Emitted when the server receives an accepted packet
signal on_server_packet_info(id: int, packet: PacketInfo)

var connection: ENetConnection
var available_peer_ids = range(255, -1, -1) # Max 255 Ids
var client_peers: Dictionary[int, ENetPacketPeer]
var packet_registry: PacketRegistry

func process() -> void:
	if connection == null: return
	_process_events()

func start_server(address: String = "127.0.0.1", port: int = 7000) -> void:
	if connection:
		push_error("Unable to start server, server is already running...")
		return
		
	connection = ENetConnection.new()
	var error = connection.create_host_bound(address, port)
	if error != OK:
		push_error("Unable to create server on [%s:%d]" % [address, port])
		connection = null
		return
	print("Server started on [%s:%d]" % [address, port])

	
func broadcast(packet: PackedByteArray, flag: int = ENetPacketPeer.FLAG_RELIABLE, channel: int = 0) ->  void:
	if connection:
		connection.broadcast(channel, packet, flag)


func send_to_peer(peer_id: int, packet: PackedByteArray, flag: int = ENetPacketPeer.FLAG_RELIABLE, channel: int = 0) -> void:
	if peer_id < 0 || !client_peers.has(peer_id):
		return
	client_peers[peer_id].send(channel, packet, flag)
	
	
func _init(_packet_registry: PacketRegistry):
	packet_registry = _packet_registry
	
	
func _process_events() -> void:
	var packet_event := connection.service()
	var event_type: ENetConnection.EventType = packet_event[0]
	while event_type != ENetConnection.EVENT_NONE:
		var peer: ENetPacketPeer = packet_event[1]
		
		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("Packet resulted in an error...")
			ENetConnection.EVENT_CONNECT:
				_peer_connected(peer)
			ENetConnection.EVENT_DISCONNECT:
				_peer_disconnected(peer)
			ENetConnection.EVENT_RECEIVE:
				var data: PackedByteArray = peer.get_packet()
				_handle_server_packet(data, peer)
		# Get next packet
		packet_event = connection.service()
		event_type = packet_event[0]

func _handle_server_packet(data: PackedByteArray, peer: ENetPacketPeer) -> void:
	var peer_id: int = peer.get_meta("id")
	if peer_id == null || !client_peers.has(peer_id):
		push_error("[Server] Malformed packet recieved, packet id missing or not registered.")
		return
		
	on_server_packet.emit(peer_id, data)
	
	var packet: PacketInfo = packet_registry.create_packet(data)
	if packet == null:
		return
	
	if packet is PingPacket:
		send_to_peer(peer_id, data)
		return # early return to keep ping packet internal
		
	on_server_packet_info.emit(peer_id, packet)

	
func _peer_connected(peer: ENetPacketPeer) -> void:
	var id: int = available_peer_ids.pop_back()
	peer.set_meta("id", id)
	client_peers[id] = peer
	on_peer_connected.emit(id)
	print("[Server] Peer connected [%d]" % id)
	var packet: IdAssignmentPacket = IdAssignmentPacket.create(id, client_peers.keys())
	broadcast(packet.encode())

	
func _peer_disconnected(peer: ENetPacketPeer) -> void:
	if not peer.has_meta("id"):
		return
	var id: int = peer.get_meta("id")
	available_peer_ids.push_back(id)
	
	if not client_peers.has(id):
		return
	
	client_peers.erase(id)
	on_peer_disconnected.emit(id)
	print("[Server] Peer disconnected [%d]" % id)
