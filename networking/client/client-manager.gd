class_name ClientManager

## Emitted when the client id is set
signal on_client_id_assignment(id_assignment_packet: IdAssignmentPacket)

## Emitted when the client connects to the server
signal on_connected_to_server()

## Emitted when the client disconnects from the server
signal on_disconnected_from_server()

## Emitted when a valid client packet is received
signal on_client_packet(packet: PacketInfo)

## Emitted when a server responds with a ping this is the current ping in milliseconds
signal on_ping(ping_ms: int)

var client_id: int = -1
var client_peer_ids: Array[int] = []
var packet_registry: PacketRegistry
var identity_provider: IdentityProvider = IdentityProvider.new()
var server_peer: ENetPacketPeer
var connection: ENetConnection
var ping_ms: int = 0 # historical ping value updates after we recieve a ping packet
var network_settings: NetworkSettings

var _attempt_connect: bool = true

func _init(_packet_registry: PacketRegistry) -> void:
	packet_registry = _packet_registry
	

func process() -> void:
	if connection == null: return
	_process_events()

	
func start_client(_network_settings: NetworkSettings, attempt_connect: bool = true) -> void:
	_attempt_connect = attempt_connect
	identity_provider.network_settings = _network_settings
	network_settings = _network_settings
	if connection:
		print("[Client] Connection already exists!")
		return
		
	connection = ENetConnection.new()
	var error: int = connection.create_host(1)
	if error != OK:
		push_error("Unable to create client")
		connection = null
		return
	server_peer = connection.connect_to_host(network_settings.address, network_settings.port)
	

func handle_disconnect() -> void:
	if server_peer != null:
		server_peer.peer_disconnect()
	server_peer = null
	client_id = -1
	client_peer_ids = []
	connection = null
	

func send_ping() -> void:
	if server_peer == null:
		return
	var ping_packet: PingPacket = PingPacket.new()
	ping_packet.timestamp = Time.get_ticks_msec()
	send_to_server(ping_packet.encode())	
	
	
func send_to_server(packet: PackedByteArray, flag: int = ENetPacketPeer.FLAG_RELIABLE, channel: int = 0) -> void:
	if server_peer:
		server_peer.send(channel, packet, flag)


## Determines if the provided id is a client and is THIS client
func is_authority(id: int) -> bool:
	return connection != null and id == client_id
	
		
func _process_events() -> void:
	var packet_event: Array = connection.service()
	var event_type: ENetConnection.EventType = packet_event[0]
	while event_type != ENetConnection.EVENT_NONE:
		var peer: ENetPacketPeer = packet_event[1]
		
		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("Packet resulted in an error...")
			ENetConnection.EVENT_CONNECT:
				_connected_to_server()
			ENetConnection.EVENT_DISCONNECT:
				_disconnected_to_server()
				return
			ENetConnection.EVENT_RECEIVE:
				var data: PackedByteArray = peer.get_packet()
				_handle_client_packet(data)
		
		# check if connection has been disconnected before processing next events
		if connection == null: return
		
		# Get next packet
		packet_event = connection.service()
		event_type = packet_event[0]


func _handle_connect_id(id_assignment_packet: IdAssignmentPacket) -> void:
	# If we receive a packet and our current id is -1 then it must be for us
	if client_id != -1: return
	client_id = id_assignment_packet.id
	client_peer_ids = id_assignment_packet.remote_ids
	

func _handle_client_packet(data: PackedByteArray) -> void:
	var packet: PacketInfo = packet_registry.create_packet(data)
	
	# check if packet type was registered
	if packet == null: return
	
	if packet is IdAssignmentPacket:
		_handle_connect_id(packet)
		on_client_id_assignment.emit(packet)
		
		if _attempt_connect:
			var handshake_packet: HandshakePacket = HandshakePacket.new()
			handshake_packet.game_version = network_settings.game_version
			handshake_packet.packet_version = network_settings.packet_version
			handshake_packet.identity = identity_provider.client_handshake_data().encode()
			send_to_server(handshake_packet.encode())
		else:
			# since we are not trying to actually access the game server
			# just request for the server to send back the server info
			send_to_server(ServerInfoRequestPacket.new().encode())
		
	if packet is PingPacket:
		ping_ms = Time.get_ticks_msec() - packet.timestamp
		on_ping.emit(ping_ms)
		return # return early so ping packet stays internal to client manager
		
	if packet is IdentityAuthenticationPacket:
		identity_provider.handle_authentication_response(packet as IdentityAuthenticationPacket, self)
		
	if packet is ServerInfoPacket:
		# if we are just getting information and not actually connecting
		# then just disconnect from the server here automatically...
		if _attempt_connect == false:
			handle_disconnect()
			
	on_client_packet.emit(packet)
	
	
func _connected_to_server() -> void:
	print("[Client] Connected to server")
	on_connected_to_server.emit()

	
func _disconnected_to_server() -> void:
	handle_disconnect()
	print("[Client] Disconnected from server")
	on_disconnected_from_server.emit()
