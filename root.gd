extends Node2D

@onready var start_button: Button = $StartServerButton
@onready var start_client: Button = $StartClientButton
@onready var packet_button: Button = $SendPacketButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_server_pressed)
	start_client.pressed.connect(_on_start_client_pressed)
	packet_button.pressed.connect(_on_send_packet_pressed)
	NetworkHandler.packet_forwarder.on_client_packet.connect(_handle_client_packets)


func _on_start_server_pressed() -> void:
	print("Server starting...")
	NetworkHandler.start_server()


func _on_start_client_pressed() -> void:
	print("Client connecting...")
	NetworkHandler.start_client()
	

func _on_send_packet_pressed() -> void:
	var is_auth = NetworkHandler.client_manager.is_authority(NetworkHandler.client_manager.client_id)
	print(is_auth)
	
func _handle_client_packets(packet: PacketInfo) -> void:
	if packet is IdAssignmentPacket:
		print("HEY")

	
