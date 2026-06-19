class_name IdentityProvider extends RefCounted

## This is intended to decode codeables so this needs to return the raw object that
## implements Codeable
func get_decode_object() -> Codeable:
	return Codeable.new()

## Client Handshake Data loads the client data from whatever local source, use this for
## handling something like external connections or loading local saves
func client_handshake_data() -> Codeable:
	return Codeable.new()


func authenticate(_data: Codeable) -> IdentityAuthentication:
	return IdentityAuthentication.new()
