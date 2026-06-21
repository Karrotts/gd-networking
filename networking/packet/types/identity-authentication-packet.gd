class_name IdentityAuthenticationPacket extends GenericPacketInfo

var success: bool = false
var details: PackedByteArray

func _init() -> void:
	type = get_packet_type()


func get_encode_buffer() -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_encode_buffer()
	
	buffer.put_u8(int(success))
	buffer.put_data(details)
	
	return buffer
	

func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_decode_buffer(packet)
	
	success = bool(buffer.get_u8())
	details = get_remaing_bytes(buffer)
	
	return buffer
	


func convert_generic(generic: Codeable) -> Codeable:
	generic.decode(details)
	return generic


static func get_packet_type() -> int:
	return 3
