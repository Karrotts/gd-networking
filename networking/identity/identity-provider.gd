class_name IdentityProvider extends RefCounted

var network_settings: NetworkSettings

## This is intended to decode codeables so this needs to return the raw object that
## implements Codeable
func get_client_decode() -> Codeable:
	return Codeable.new()
	
## This is intended to be used to decode the authentication packets. This should return a object
## that implements Codeable that is used for authentication packets
func get_authentication_decode() -> Codeable:
	return Codeable.new()

## Client Handshake Data loads the client data from whatever local source, use this for
## handling something like external connections or loading local saves
func client_handshake_data() -> Codeable:
	return Codeable.new()


func authenticate(_data: Codeable) -> IdentityAuthenticationPacket:
	return IdentityAuthenticationPacket.new()


## This is used to handle authentication responses from the server. Use this to determine if the player can
## continue conencting to the server or disconnect if they are unauthenticated.
func handle_authentication_response(_identity: IdentityAuthenticationPacket, _client_manger: ClientManager) -> void:
	pass
