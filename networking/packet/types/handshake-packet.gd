class_name HandshakePacket extends PacketInfo

const PACKET_TYPE = 2

var game_version: String = "0.0.0"
var packet_version: String = "0"
var client_identifier: String = ""
var client_identifier_secret: String = ""

func _init() -> void:
	type = PACKET_TYPE

func encode() -> PackedByteArray:
	var data := super.encode()

	var buffer := StreamPeerBuffer.new()
	buffer.data_array = data

	buffer.seek(data.size())

	buffer.put_string(game_version)
	buffer.put_string(packet_version)
	buffer.put_string(client_identifier)
	buffer.put_string(client_identifier_secret)

	return buffer.data_array

func decode(packet: PackedByteArray) -> void:
	super.decode(packet)

	var buffer := StreamPeerBuffer.new()
	buffer.data_array = packet

	buffer.seek(1) # Skip packet type

	game_version = buffer.get_string()
	packet_version = buffer.get_string()
	client_identifier = buffer.get_string()
	client_identifier_secret = buffer.get_string()
