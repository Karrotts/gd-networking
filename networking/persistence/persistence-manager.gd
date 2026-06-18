class_name PersistenceManager extends RefCounted

const USER_FILE := "user://network_users.json"

var users: Dictionary = {}


func _init() -> void:
	load_users()


func load_users() -> void:
	users.clear()

	if !FileAccess.file_exists(USER_FILE):
		save_users()
		return

	var file := FileAccess.open(USER_FILE, FileAccess.READ)

	if file == null:
		return

	var json: Dictionary = JSON.parse_string(file.get_as_text())

	if json is Dictionary:
		users = json


func save_users() -> void:
	var file := FileAccess.open(USER_FILE, FileAccess.WRITE)

	if file == null:
		return

	file.store_string(JSON.stringify(users, "\t"))


func create_user() -> Dictionary:
	var uuid := generate_uuid()
	var secret := generate_secret()

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


func generate_uuid() -> String:
	return str(ResourceUID.create_id())


func generate_secret() -> String:
	var bytes := PackedByteArray()

	for i in range(32):
		bytes.append(randi() % 256)

	return bytes.hex_encode()
