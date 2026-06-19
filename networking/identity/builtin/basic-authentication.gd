class_name BasicAuthentication extends Codeable

var client_id: String
var secret: String

func encode() -> PackedByteArray:
	var data := super.encode()
	
	var buffer := StreamPeerBuffer.new()
	buffer.data_array = data

	buffer.seek(data.size())
	buffer.put_string(client_id)
	buffer.put_string(secret)
	
	return buffer.data_array

func decode(_packet: PackedByteArray) -> void:
	super.decode(_packet)
	
	var buffer := StreamPeerBuffer.new()
	buffer.data_array = _packet
	
	client_id = buffer.get_string()
	secret = buffer.get_string()
	
