class_name BasicIdentity extends Codeable

var client_id: String
var secret: String

func encode() -> PackedByteArray:
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()

	buffer.put_string(client_id)
	buffer.put_string(secret)
	
	return buffer.data_array


func decode(_packet: PackedByteArray) -> void:
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = _packet
	
	client_id = buffer.get_string()
	secret = buffer.get_string()
	
