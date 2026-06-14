## This script is game dependent, this is used to emit signals when certain packets arrive

extends Node

func _ready() -> void:
	NetworkHandler.on_client_packet.connect(_handle_client_packet)
	NetworkHandler.on_server_packet.connect(_handle_server_packet)
	

func _handle_server_packet(_id: int, _data: PackedByteArray) -> void:
	var packet: PacketInfo = NetworkHandler.packet_registry.create_packet(_data)
	
	# check if packet type was registered
	if packet == null: return


func _handle_client_packet(_data: PackedByteArray) -> void:
	var packet: PacketInfo = NetworkHandler.packet_registry.create_packet(_data)
	
	# check if packet type was registered
	if packet == null: return
	
