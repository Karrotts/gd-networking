class_name PingPacket extends PacketInfo

var timestamp: int

func _init() -> void:
	type = get_packet_type()


func get_encode_buffer() -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_encode_buffer()
	
	buffer.put_64(timestamp)
	
	return buffer
	

func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_decode_buffer(packet)
	
	timestamp = buffer.get_64()
	
	return buffer
	

static func get_packet_type() -> int:
	return 1
