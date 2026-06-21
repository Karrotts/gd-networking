class_name ServerInfoRequestPacket extends PacketInfo

var request_id: String

func _init() -> void:
	type = get_packet_type()

func get_encode_buffer() -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_encode_buffer()
	
	buffer.put_string(request_id)
	
	return buffer

func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_decode_buffer(packet)
	
	request_id = buffer.get_string()
	
	return buffer
	

static func get_packet_type() -> int:
	return 4
