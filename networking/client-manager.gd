class_name ClientManager extends Node

## Emitted when the client id is set
signal on_client_id_assignment(id_assignment_packet: IdAssignmentPacket)

var client_id: int = -1
var client_peer_ids: Array[int] = []

func _init() -> void:
	NetworkHandler.on_client_packet.connect(_handle_client_packet)


func handle_connect(id_assignment_packet: IdAssignmentPacket) -> void:
	# If we receive a packet and our current id is -1 then it must be for us
	if client_id != -1: return
	client_id = id_assignment_packet.id
	client_peer_ids = id_assignment_packet.remote_ids
	

func handle_disconnect() -> void:
	client_id = -1
	client_peer_ids = []


## Determines if the provided id is a client and is THIS client
func is_authority(id: int) -> bool:
	return !NetworkHandler.is_server and id == client_id


func _handle_client_packet(data: PackedByteArray) -> void:
	var packet: PacketInfo = NetworkHandler.packet_registry.create_packet(data)
	
	# check if packet type was registered
	if packet == null: return
	
	if packet is IdAssignmentPacket:
		handle_connect(packet)
		on_client_id_assignment.emit(packet)
