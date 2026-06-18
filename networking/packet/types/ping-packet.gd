class_name PingPacket extends PacketInfo

const PACKET_TYPE: int = 1 

var timestamp: int

func encode() -> PackedByteArray:
	type = PACKET_TYPE
	var packet := super.encode()

	packet.append_array(
		PackedByteArray(var_to_bytes(timestamp))
	)

	return packet

func decode(packet: PackedByteArray):
	super.decode(packet)

	timestamp = bytes_to_var(
		packet.slice(1)
	)
