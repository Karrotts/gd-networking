class_name ServerInfoPacket extends PacketInfo

var response_id: String
var server_settings: ServerSettings
var connected_users: int = 0
var timestamp: int

func _init() -> void:
	type = get_packet_type()


func get_encode_buffer() -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_encode_buffer()

	buffer.put_string(response_id)
	buffer.put_string(server_settings.server_name)
	buffer.put_string(server_settings.server_description)
	buffer.put_16(server_settings.max_allowed_players)
	buffer.put_16(connected_users)
	buffer.put_64(timestamp)
	
	return buffer

func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_decode_buffer(packet)
	
	server_settings = ServerSettings.new()
	response_id = buffer.get_string()
	server_settings.server_name = buffer.get_string()
	server_settings.server_description = buffer.get_string()
	server_settings.max_allowed_players = buffer.get_16()
	connected_users = buffer.get_16()
	timestamp = buffer.get_64()
	
	return buffer

static func get_packet_type() -> int:
	return 5
