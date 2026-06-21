class_name ServerBrowser extends Control

@export var server_item_panel: PackedScene

@onready var server_items_container: VBoxContainer = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/ServerItemsContainer
@onready var address_box: LineEdit = $MarginContainer/VBoxContainer/ServerAddMenu/AddressContainer/AddressBox
@onready var port_box: LineEdit = $MarginContainer/VBoxContainer/ServerAddMenu/PortContainer/PortBox
@onready var add_server_button: Button = $MarginContainer/VBoxContainer/ServerAddMenu/AddServerButton

var _servers: Dictionary = {}

func _ready() -> void:
	NetworkHandler.client_manager.on_client_packet.connect(_handle_network_packets)
	add_server_button.pressed.connect(_add_server)
	
func _add_server() -> void:
	if address_box.text != "" && port_box.text != "":
		var server_name: String = address_box.text + ":" + port_box.text
		var port: int = int(port_box.text)
		
		# if this was an actual game we should do more advanced checks here for port validatity
		if port == 0:
			print("Invalid port [%d]!" % port)
			return
		
		# no need to add settings if it already exists
		if _servers.has(server_name):
			return
		
		var settings: NetworkSettings = NetworkSettings.new()
		settings.address = address_box.text
		settings.port = port
		
		var item: ServerItemPanel = server_item_panel.instantiate() as ServerItemPanel
		item.network_settings = settings
		server_items_container.add_child(item)
		_servers[server_name] = item
		
		NetworkHandler.client_manager.start_client(settings, false)

func _handle_network_packets(packet: PacketInfo) -> void:
	if packet is ServerInfoPacket:
		if _servers.has(packet.response_id):
			var item: ServerItemPanel = _servers[packet.response_id]
			item.set_info(packet.server_settings, packet.connected_users, Time.get_ticks_msec() - packet.timestamp)
