class_name PingPacket extends PacketInfo

const PACKET_TYPE: int = 1 

var timestamp: int

func _init() -> void:
	type = PACKET_TYPE

func encode() -> PackedByteArray:
	var packet: PackedByteArray = super.encode()

	packet.append_array(
		PackedByteArray(var_to_bytes(timestamp))
	)

	return packet

func decode(packet: PackedByteArray) -> void:
	super.decode(packet)

	timestamp = bytes_to_var(
		packet.slice(1)
	)
