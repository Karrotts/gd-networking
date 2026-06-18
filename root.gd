extends Node2D

@onready var start_button: Button = $StartServerButton
@onready var start_client: Button = $StartClientButton
@onready var packet_button: Button = $SendPacketButton
@onready var ping: Label = $Ping

func _ready() -> void:
	start_button.pressed.connect(_on_start_server_pressed)
	start_client.pressed.connect(_on_start_client_pressed)
	packet_button.pressed.connect(_on_send_packet_pressed)
	NetworkHandler.client_manager.on_client_packet.connect(_handle_client_packets)
	NetworkHandler.client_manager.on_ping.connect(_handle_ping_update)

func _process(_delta: float) -> void:
	NetworkHandler.client_manager.send_ping()

func _on_start_server_pressed() -> void:
	print("Server starting...")
	NetworkHandler.server_manager.start_server(ServerSettings.new())


func _on_start_client_pressed() -> void:
	print("Client connecting...")
	NetworkHandler.client_manager.start_client(NetworkSettings.new())
	

func _on_send_packet_pressed() -> void:
	var is_auth = NetworkHandler.client_manager.is_authority(NetworkHandler.client_manager.client_id)
	print(is_auth)
	
	
func _handle_client_packets(packet: PacketInfo) -> void:
	if packet is IdAssignmentPacket:
		print("Client received ID: " + str(packet.id))
		
		
func _handle_ping_update(ping_ms: int) -> void:
	ping.text = "Ping: " + str(ping_ms) + " ms"

	
