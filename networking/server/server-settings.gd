class_name ServerSettings extends NetworkSettings

const SERVER_DIR: String = "user://server"
const SERVER_CONFIG: String = SERVER_DIR + "/server_config.json"

var game_version_must_match: bool = true
var packet_version_must_match: bool = true
var server_name: String = "Unnamed Server"
var server_description: String = "All are welcome to this server!"
var max_allowed_players: int = 256

func _init() -> void:
	load_from_file()

func load_from_file() -> void:
	var file: FileAccess = FileAccess.open(SERVER_CONFIG, FileAccess.READ)
	
	if file == null:
		save_to_file()
		return
		
	var json: Dictionary = JSON.parse_string(file.get_as_text())
	if json is Dictionary:
		address = json["address"]
		port = json["port"]
		server_name = json["server_name"]
		server_description = json["server_description"]
		max_allowed_players = json["max_allowed_players"]
	

func save_to_file() -> void:
	_create_dir()
	var file: FileAccess = FileAccess.open(SERVER_CONFIG, FileAccess.WRITE)

	if file == null:
		return
		
	var data: Dictionary = {
		"address": address,
		"port": port,
		"server_name": server_name,
		"server_description": server_description,
		"max_allowed_players": max_allowed_players
	}

	file.store_string(JSON.stringify(data, "\t"))
	
	

func _create_dir() -> void:
	var dir: DirAccess = DirAccess.open(SERVER_DIR)
	
	if dir:
		return
		
	DirAccess.make_dir_absolute(SERVER_DIR)
