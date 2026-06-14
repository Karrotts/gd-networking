class_name PacketForwarder extends Node

signal on_server_packet(id: int, packet: PacketInfo)
signal on_client_packet(packet: PacketInfo)

func handle_server_packet(_id: int, _data: PackedByteArray) -> void:
	var packet: PacketInfo = NetworkHandler.packet_registry.create_packet(_data)
	on_server_packet.emit(_id, packet)


func handle_client_packet(_data: PackedByteArray) -> void:
	var packet: PacketInfo = NetworkHandler.packet_registry.create_packet(_data)
	on_client_packet.emit(packet)
