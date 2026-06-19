class_name BasicIdentityProvider extends IdentityProvider

func get_client_decode() -> Codeable:
	return BasicAuthentication.new()

func client_handshake_data() -> Codeable:
	var auth: BasicAuthentication = BasicAuthentication.new()
	# TODO data loading
	auth.client_id = "54321"
	auth.secret = "943027"
	return auth

func authenticate(_data: Codeable) -> IdentityAuthenticationPacket:
	# Failed auth since we were not given a valid packet
	var auth: IdentityAuthenticationPacket = IdentityAuthenticationPacket.new()
	if _data is BasicAuthentication:
		var data: BasicAuthentication = _data as BasicAuthentication
		print("[Server] Basic Authentication: [%s] [%s]" % [data.client_id, data.secret])
		if data.client_id != "" and data.secret != "":
			auth.success = _validate_auth(data.client_id, data.secret)
			auth.details = _data.encode()
		else:
			auth.success = true
			auth.details = _create_new_auth().encode()	
	return auth
	
func handle_authentication_response(_identity: IdentityAuthenticationPacket, _client_manger: ClientManager) -> void:
	var _auth: BasicAuthentication = _identity.convert_generic(get_client_decode())
	if !_identity.success:
		print("Invalid identity authentication response from server, disconnecting...")
		_client_manger.handle_disconnect()
		return
	print("Welcome %s!" % _auth.client_id)
	pass

func _create_new_auth() -> BasicAuthentication:
	var auth: BasicAuthentication = BasicAuthentication.new()
	# TODO implement auth
	auth.client_id = "12345"
	auth.secret = "123456"
	return auth

func _validate_auth(_client_id: String, _secret: String) -> bool:
	# TODO validation
	return true

	
