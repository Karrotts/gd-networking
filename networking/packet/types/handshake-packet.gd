class_name HandshakePacket extends GenericPacketInfo

const PACKET_TYPE = 2

var game_version: String = "0.0.0"
var packet_version: String = "0"
var identity: PackedByteArray

func _init() -> void:
	type = PACKET_TYPE

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()

	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = data

	buffer.seek(data.size())

	buffer.put_string(game_version)
	buffer.put_string(packet_version)
	buffer.put_data(identity)

	return buffer.data_array

func decode(packet: PackedByteArray) -> void:
	super.decode(packet)

	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = packet

	buffer.seek(1) # Skip packet type

	game_version = buffer.get_string()
	packet_version = buffer.get_string()
	identity = get_remaing_bytes(buffer)
	

func convert_generic(generic: Codeable) -> Codeable:
	generic.decode(identity)
	return generic
