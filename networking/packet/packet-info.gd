class_name PacketInfo extends Codeable

var type: int # always the first byte of a packet

func encode() -> PackedByteArray:
	var data: PackedByteArray
	data.resize(1)
	data.encode_u8(0, type)
	return data
	
	
func decode(packet: PackedByteArray) -> void:
	type = packet.decode_u8(0)


## Returns the remaining bytes in a buffer, good for if you need to decode whatever is left
## in a buffer
func get_remaing_bytes(buffer: StreamPeerBuffer) -> PackedByteArray:
	var remaining: int = buffer.get_available_bytes()
	return buffer.get_data(remaining)[1]
