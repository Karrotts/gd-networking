class_name ServerInfoPacket extends PacketInfo

const PACKET_TYPE: int = 5

var server_settings: ServerSettings
var connected_users: int = 0
var timestamp: int

func _init() -> void:
	type = PACKET_TYPE
	
func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()

	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = data

	buffer.seek(data.size())
	
	buffer.put_string(server_settings.server_name)
	buffer.put_string(server_settings.server_description)
	buffer.put_16(server_settings.max_allowed_players)
	buffer.put_16(connected_users)
	buffer.put_64(timestamp)
	
	return buffer.data_array

func decode(packet: PackedByteArray) -> void:
	super.decode(packet)

	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = packet

	buffer.seek(1) # Skip packet type
	
	server_settings = ServerSettings.new()
	server_settings.server_name = buffer.get_string()
	server_settings.server_description = buffer.get_string()
	server_settings.max_allowed_players = buffer.get_16()
	connected_users = buffer.get_16()
	timestamp = buffer.get_64()