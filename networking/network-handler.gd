extends Node

var packet_registry: PacketRegistry = PacketRegistry.new()
var client_manager: ClientManager =  ClientManager.new(packet_registry)
var server_manager: ServerManager = ServerManager.new(packet_registry)

func _process(_delta: float) -> void:
	client_manager.process()
	server_manager.process()
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		client_manager.handle_disconnect()
