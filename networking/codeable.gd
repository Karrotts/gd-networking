class_name Codeable extends RefCounted

func encode() -> PackedByteArray:
	return []
	
	
func decode(_packet: PackedByteArray) -> void:
	pass


func get_decode_buffer(packet: PackedByteArray) -> StreamPeerBuffer:
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = packet
	return buffer
	

func get_encode_buffer() -> StreamPeerBuffer:
	return StreamPeerBuffer.new()
