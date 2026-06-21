class_name PacketInfo extends Codeable

var type: int # always the first byte of a packet

func encode() -> PackedByteArray:
	return get_encode_buffer().data_array
	
	
func decode(packet: PackedByteArray) -> void:
	get_decode_buffer(packet)
	

func get_encode_buffer() -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_encode_buffer()
	
	buffer.put_8(type)
	
	return buffer


func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_decode_buffer(packet)
	
	type = buffer.get_8()
	
	return buffer


## Returns the remaining bytes in a buffer, good for if you need to decode whatever is left
## in a buffer
func get_remaing_bytes(buffer: StreamPeerBuffer) -> PackedByteArray:
	var remaining: int = buffer.get_available_bytes()
	return buffer.get_data(remaining)[1]


## Returns the packet type. This is used for packet registry for finding the conversion packet type.
static func get_packet_type() -> int:
	return -1
