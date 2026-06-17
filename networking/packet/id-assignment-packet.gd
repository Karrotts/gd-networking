class_name IdAssignmentPacket extends PacketInfo

const PACKET_TYPE = 0

var id: int
var remote_ids: Array[int]

static func create(_id: int, _remote_ids: Array[int]) -> IdAssignmentPacket:
	var data: IdAssignmentPacket = IdAssignmentPacket.new()
	data.type = PACKET_TYPE
	data.id = _id
	data.remote_ids = _remote_ids
	return data


static func create_from_packet(packet: PackedByteArray) -> IdAssignmentPacket:
	var data: IdAssignmentPacket = IdAssignmentPacket.new()
	data.decode(packet)
	return data


func encode() -> PackedByteArray:
	var packet: PackedByteArray = super.encode()
	packet.resize(2 + remote_ids.size())
	packet.encode_u8(1, id)
	for i in remote_ids.size():
		packet.encode_u8(2 + i, remote_ids[i])
	return packet


func decode(packet: PackedByteArray) -> void:
	super.decode(packet)
	id = packet.decode_u8(1)
	remote_ids = []
	for i in range(2, packet.size()):
		remote_ids.append(packet.decode_u8(i))
	
