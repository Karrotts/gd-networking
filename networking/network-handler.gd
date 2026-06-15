extends Node

# Server side signals


### Emitted when the server receives a packet. Contains the Id and the packet data.
#signal on_server_packet(id: int, data: PackedByteArray)
#
## Client side signals
#
#
### Emitted when the client receives a packet. Contains the packet data.
#signal on_client_packet(data: PackedByteArray)

# Server vars
var available_peer_ids = range(255, -1, -1) # Max 255 Ids
var client_peers: Dictionary[int, ENetPacketPeer]

# Client vars
var server_peer: ENetPacketPeer

# General
#var connection: ENetConnection
#var is_server: bool
var packet_registry: PacketRegistry = PacketRegistry.new()
var packet_forwarder: PacketForwarder = PacketForwarder.new(packet_registry)
var client_manager: ClientManager =  ClientManager.new(packet_registry)
var server_manager: ServerManager = ServerManager.new(packet_registry)


func _process(_delta: float) -> void:
	client_manager.process()
	server_manager.process()


#func _handle_events() -> void:
	#var packet_event := connection.service()
	#var event_type: ENetConnection.EventType = packet_event[0]
	#while event_type != ENetConnection.EVENT_NONE:
		#var peer: ENetPacketPeer = packet_event[1]
		#
		#match event_type:
			#ENetConnection.EVENT_ERROR:
				#push_warning("Packet resulted in an error...")
			#ENetConnection.EVENT_CONNECT:
				#if is_server:
					#_peer_connected(peer)
				#else:
					#_connected_to_server()
			#ENetConnection.EVENT_DISCONNECT:
				#if is_server:
					#_peer_disconnected(peer)
				#else:
					#_disconnected_to_server()
					#return
			#ENetConnection.EVENT_RECEIVE:
				#var data: PackedByteArray = peer.get_packet()
				#if is_server:
					#on_server_packet.emit(peer.get_meta("id"), data)
					#packet_forwarder.handle_server_packet(peer.get_meta("id"), data)
				#else:
					#on_client_packet.emit(data)
					#packet_forwarder.handle_client_packet(data)
					#client_manager.handle_client_packet(data)
		## Get next packet
		#packet_event = connection.service()
		#event_type = packet_event[0]
		

#func start_server(address: String = "127.0.0.1", port: int = 7000) -> void:
	#server_manager.connection = ENetConnection.new()
	#var error = server_manager.connection.create_host_bound(address, port)
	#if error != OK:
		#push_error("Unable to create server on [%s:%d]" % [address, port])
		#server_manager.connection = null
		#return
	#print("Server started on [%s:%d]" % [address, port])
	#is_server = true
	#server_manager.is_server = true
	#client_manager.is_server = true
	

#func start_client(address: String = "127.0.0.1", port: int = 7000) -> void:
	#client_manager.connection = ENetConnection.new()
	#var error = client_manager.connection.create_host(1)
	#if error != OK:
		#push_error("Unable to create client")
		#client_manager.connection = null
		#return
	#client_manager.server_peer = client_manager.connection.connect_to_host(address, port)


#func disconnect_client() -> void:
	#if is_server: return
	#if server_peer != null:
		#server_peer.peer_disconnect()
		#client_manager.handle_disconnect()


#func broadcast(packet: PackedByteArray, flag: int = ENetPacketPeer.FLAG_RELIABLE, channel: int = 0) ->  void:
	#if connection:
		#connection.broadcast(channel, packet, flag)
	#
#
#func send(peer: ENetPacketPeer, packet: PackedByteArray, flag: int = ENetPacketPeer.FLAG_RELIABLE, channel: int = 0) -> void:
	#peer.send(channel, packet, flag)
	

#func _peer_connected(peer: ENetPacketPeer) -> void:
	#var id: int = available_peer_ids.pop_back()
	#peer.set_meta("id", id)
	#client_peers[id] = peer
	#on_peer_connected.emit(id)
	#print("[Server] Peer connected [%d]" % id)
	#var packet: IdAssignmentPacket = IdAssignmentPacket.create(id, client_peers.keys())
	#broadcast(packet.encode())


#func _peer_disconnected(peer: ENetPacketPeer) -> void:
	#if not peer.has_meta("id"):
		#return
	#var id: int = peer.get_meta("id")
	#available_peer_ids.push_back(id)
	#
	#if not client_peers.has(id):
		#return
	#
	#client_peers.erase(id)
	#on_peer_disconnected.emit(id)
	#print("[Server] Peer disconnected [%d]" % id)


#func _connected_to_server() -> void:
	#print("[Client] Connected to server")
	#on_connected_to_server.emit()
#
	#
#func _disconnected_to_server() -> void:
	#print("[Client] Disconnected from server")
	#on_disconnected_from_server.emit()
	#connection = null
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		client_manager.handle_disconnect()
