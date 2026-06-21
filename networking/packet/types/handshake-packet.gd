class_name HandshakePacket extends GenericPacketInfo

var game_version: String = "0.0.0"
var packet_version: String = "0"
var identity: PackedByteArray

func _init() -> void:
	type = get_packet_type()
	

func get_encode_buffer() -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_encode_buffer()
	
	buffer.put_string(game_version)
	buffer.put_string(packet_version)
	buffer.put_data(identity)
	
	return buffer


func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_decode_buffer(packet)
	
	game_version = buffer.get_string()
	packet_version = buffer.get_string()
	identity = get_remaing_bytes(buffer)
	
	return buffer


func convert_generic(generic: Codeable) -> Codeable:
	generic.decode(identity)
	return generic
	

static func get_packet_type() -> int:
	return 2
