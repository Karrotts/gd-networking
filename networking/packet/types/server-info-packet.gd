class_name ServerInfoPacket extends PacketInfo

const PACKET_TYPE: int = 5

var server_settings: ServerSettings
var connected_users: int = 0
var ping_ms: int = 0

func _init() -> void:
	type = PACKET_TYPE
	
func encode() -> PackedByteArray:
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	
	if server_settings != null:
		buffer.put_string(server_settings.server_name)
		buffer.put_string(server_settings.server_description)
	
	return buffer.data_array
