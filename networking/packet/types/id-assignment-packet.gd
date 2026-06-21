class_name IdAssignmentPacket extends PacketInfo

var id: int
var remote_ids: Array[int]
	
func _init() -> void:
	type = get_packet_type()


func get_encode_buffer() -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_encode_buffer()
	
	buffer.put_8(id)
	buffer.put_8(remote_ids.size())
	
	for i: int in remote_ids.size():
		buffer.put_8(remote_ids[i])
	
	return buffer


func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = super.get_decode_buffer(packet)
	
	id = buffer.get_8()
	var remote_ids_size: int = buffer.get_8()
	remote_ids = []
	for i: int in remote_ids_size:
		remote_ids.append(buffer.get_8())
	
	return buffer


static func get_packet_type() -> int:
	return 0
