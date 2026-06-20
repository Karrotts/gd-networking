class_name BasicIdentityProvider extends IdentityProvider

const SERVER_DIR: String = "user://server"
const SERVER_USERS: String = SERVER_DIR + "/server_users.json"
const USER_INFO: String = "user://server_user_info.json"

var users: Dictionary = {}
var servers: Dictionary = {}

func get_authentication_decode() -> Codeable:
	return BasicIdentity.new()


func get_client_decode() -> Codeable:
	return BasicIdentity.new()


func client_handshake_data() -> Codeable:
	_get_client_servers()
	
	var server_name: String = network_settings.address + ":" + str(network_settings.port)
	
	var auth: BasicIdentity = BasicIdentity.new()
	auth.client_id = ""
	auth.secret = ""
	
	if servers.has(server_name):
		auth.client_id = servers[server_name].client_id
		auth.secret = servers[server_name].secret
	
	return auth


func authenticate(_data: Codeable) -> IdentityAuthenticationPacket:
	_get_server_users()
	
	var auth: IdentityAuthenticationPacket = IdentityAuthenticationPacket.new()
	if _data is BasicIdentity:
		var data: BasicIdentity = _data as BasicIdentity
		print("[Server] Basic Authentication: [%s] [%s]" % [data.client_id, data.secret])
		if data.client_id != "" and data.secret != "":
			auth.success = _validate_auth(data.client_id, data.secret)
			auth.details = _data.encode()
		else:
			auth.success = true
			auth.details = _create_new_auth().encode()	
	return auth
	

func handle_authentication_response(_identity: IdentityAuthenticationPacket, _client_manger: ClientManager) -> void:
	var _auth: BasicIdentity = _identity.convert_generic(get_authentication_decode())
	
	var server_name: String = network_settings.address + ":" + str(network_settings.port)
	
	var user_auth: Dictionary = {
		"client_id": _auth.client_id,
		"secret": _auth.secret,
		"last_auth": Time.get_unix_time_from_system()
	}
	
	servers[server_name] = user_auth
	_save(USER_INFO, servers)
	
	if !_identity.success:
		print("Invalid identity authentication response from server, disconnecting...")
		_client_manger.handle_disconnect()
		return
	print("Welcome %s!" % _auth.client_id)
	pass

	
func _get_client_servers(reload: bool = false) -> Dictionary:
	if servers == null || servers.size() == 0 || reload:
		servers.clear()
		servers = _load(USER_INFO)
	return servers


func _get_server_users(reload: bool = false) -> Dictionary:
	if users == null || users.size() == 0 || reload:
		users.clear()
		_create_dir()
		users = _load(SERVER_USERS)
	return users


func _create_new_auth() -> BasicIdentity:
	var auth: BasicIdentity = BasicIdentity.new()
	
	auth.client_id = _generate_uuid()
	auth.secret = _generate_secret()
	
	users[auth.client_id] = {
		"secret": auth.secret,
		"first_seen": Time.get_unix_time_from_system(),
		"last_seen": Time.get_unix_time_from_system()
	}
	_save_server_users()

	return auth


func _validate_auth(_client_id: String, _secret: String) -> bool:
	if !users.has(_client_id):
		return false

	if users[_client_id]["secret"] != _secret:
		return false

	users[_client_id]["last_seen"] = Time.get_unix_time_from_system()
	_save_server_users()

	return true
	
	
func _load(file_name: String) -> Dictionary:
	
	if !FileAccess.file_exists(file_name):
		_save(file_name, {})
		return { }

	var file: FileAccess = FileAccess.open(file_name, FileAccess.READ)

	if file == null:
		return { }
	
	var json: Dictionary = JSON.parse_string(file.get_as_text())

	if json is Dictionary:
		return json
	return { }


func _save(file_name: String, data: Dictionary) -> void:
	var file: FileAccess = FileAccess.open(file_name, FileAccess.WRITE)

	if file == null:
		return

	file.store_string(JSON.stringify(data, "\t"))


func _save_server_users() -> void:
	_create_dir()
	_save(SERVER_USERS, users)


func _generate_uuid() -> String:
	return str(ResourceUID.create_id())


func _generate_secret() -> String:
	var bytes: PackedByteArray = PackedByteArray()

	for i: int in range(32):
		bytes.append(randi() % 256)

	return bytes.hex_encode()


func _create_dir() -> void:
	var dir: DirAccess = DirAccess.open(SERVER_DIR)
	
	# check if directory already exists
	if dir:
		return
		
	DirAccess.make_dir_absolute(SERVER_DIR)
