class_name ServerPersistenceManager extends RefCounted

const USER_FILE := "user://network_users.json"

var users: Dictionary = {}
var servers: Dictionary = {}
var server_info: String

func _init(_server_info: String) -> void:
	server_info = _server_info
	load_users()


func load_users() -> void:
	users.clear()
	
	if !FileAccess.file_exists(_get_file_name()):
		save_users()
		return

	var file := FileAccess.open(_get_file_name(), FileAccess.READ)

	if file == null:
		return

	var json: Dictionary = JSON.parse_string(file.get_as_text())

	if json is Dictionary:
		servers = json
		if servers.has(server_info):
			users = servers[server_info]
			print("Loaded %d users..." % users.values().size())


func save_users() -> void:
	var file := FileAccess.open(_get_file_name(), FileAccess.WRITE)

	if file == null:
		return
	
	servers[server_info] = users
	file.store_string(JSON.stringify(servers, "\t"))


func create_user() -> Dictionary:
	var uuid := _generate_uuid()
	var secret := _generate_secret()

	users[uuid] = {
		"secret": secret,
		"first_seen": Time.get_unix_time_from_system(),
		"last_seen": Time.get_unix_time_from_system()
	}

	save_users()

	return {
		"uuid": uuid,
		"secret": secret
	}


func validate(uuid: String, secret: String) -> bool:
	if !users.has(uuid):
		return false

	if users[uuid]["secret"] != secret:
		return false

	users[uuid]["last_seen"] = Time.get_unix_time_from_system()
	save_users()

	return true


func user_exists(uuid: String) -> bool:
	return users.has(uuid)


func _generate_uuid() -> String:
	return str(ResourceUID.create_id())


func _generate_secret() -> String:
	var bytes := PackedByteArray()

	for i in range(32):
		bytes.append(randi() % 256)

	return bytes.hex_encode()
	
func _get_file_name() -> String:
	return USER_FILE
