class_name BasicIdentityProvider extends IdentityProvider

func get_decode_object() -> Codeable:
	return BasicAuthentication.new()

func client_handshake_data() -> Codeable:
	var auth: BasicAuthentication = BasicAuthentication.new()
	# TODO data loading
	auth.client_id = "54321"
	auth.secret = "943027"
	return auth

func authenticate(_data: Codeable) -> IdentityAuthentication:
	# Failed auth since we were not given a valid packet
	var auth: IdentityAuthentication = IdentityAuthentication.new()
	if _data is BasicAuthentication:
		print("[Server] Basic Authentication: [%s] [%s]" % [_data.client_id, _data.secret])
		if _data.client_id != "" and _data.secret != "":
			auth.success = validate_auth(_data.client_id, _data.secret)
			auth.details = _data
		else:
			auth.success = true
			auth.details = create_new_auth()	
	return auth

func create_new_auth() -> BasicAuthentication:
	var auth: BasicAuthentication = BasicAuthentication.new()
	# TODO implement auth
	auth.client_id = "12345"
	auth.secret = "123456"
	return auth

func validate_auth(_client_id: String, _secret: String) -> bool:
	# TODO validation
	return true

	
