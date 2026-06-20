extends Node

var packet_registry: PacketRegistry = PacketRegistry.new()
var identity_provider: IdentityProvider = IdentityProvider.new()
var client_manager: ClientManager =  ClientManager.new(packet_registry)
var server_manager: ServerManager = ServerManager.new(packet_registry)

func _ready() -> void:
	var args: PackedStringArray = OS.get_cmdline_args()

	if args.has("--server"):
		print("Server starting...")
		server_manager.start_server(ServerSettings.new())

func _process(_delta: float) -> void:
	client_manager.process()
	server_manager.process()
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		client_manager.handle_disconnect()


func set_identity_provider(identity_provider: IdentityProvider) -> void:
	client_manager.identity_provider = identity_provider
	server_manager.identity_provider = identity_provider
