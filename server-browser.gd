class_name ServerBrowser extends Control

@export var server_item_panel: PackedScene

@onready var server_items_container: VBoxContainer = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/ServerItemsContainer

func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_args()
	if not args.has("--server"):
		NetworkHandler.client_manager.on_client_packet.connect(_handle_network_packets)
		NetworkHandler.client_manager.start_client(NetworkSettings.new(), false)


func _handle_network_packets(packet: PacketInfo) -> void:
	if packet is ServerInfoPacket:
		var item: ServerItemPanel = server_item_panel.instantiate() as ServerItemPanel
		server_items_container.add_child(item)
		item.set_info(packet.server_settings, packet.connected_users, Time.get_ticks_msec() - packet.timestamp)
