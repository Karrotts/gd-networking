class_name PacketRegistry

var registry: Dictionary[int, Script] = {}

func _init() -> void:
	register(IdAssignmentPacket.get_packet_type(), IdAssignmentPacket)
	register(PingPacket.get_packet_type(), PingPacket)
	register(HandshakePacket.get_packet_type(), HandshakePacket)
	register(IdentityAuthenticationPacket.get_packet_type(), IdentityAuthenticationPacket)
	register(ServerInfoRequestPacket.get_packet_type(), ServerInfoRequestPacket)
	register(ServerInfoPacket.get_packet_type(), ServerInfoPacket)


## Registers a packet with under a given packet id (or type)
func register(id: int, packet_info: Script) -> void:
	if registry.has(id):
		push_error("Packet key ["+str(id)+"] already exists in registry!")
		return
	registry[id] = packet_info


## Creates a packet from the byte array, this will return the packet as the registered
## packet type. If no registered packet type under the id, then this will return null.
func create_packet(data: PackedByteArray) -> PacketInfo:
	var id: int = data.decode_u8(0)
	
	print("[Packet Registry] Creating packet with id [%d]" % id)

	if not registry.has(id):
		push_error("Unknown packet id: %d" % id)
		return null

	var packet: PacketInfo = registry[id].new()
	packet.decode(data)
	return packet
