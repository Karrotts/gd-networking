class_name IdentityAuthenticationPacket extends GenericPacketInfo

const PACKET_TYPE: int = 3

var success: bool = false
var details: PackedByteArray

func _init() -> void:
	type = PACKET_TYPE

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = data
	
	buffer.seek(data.size())
	buffer.put_u8(int(success))
	buffer.put_data(details)
	
	return buffer.data_array

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = data

	buffer.seek(1) # Skip packet type
	
	success = bool(buffer.get_u8())
	details = get_remaing_bytes(buffer)


func convert_generic(generic: Codeable) -> Codeable:
	generic.decode(details)
	return generic
