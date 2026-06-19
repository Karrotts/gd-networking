class_name GenericPacketInfo extends PacketInfo

## Used to decode generic Codeable objects to their expected types. You need to pass in a valid codeable for this
## to work.
func convert_generic(generic: Codeable) -> Codeable:
	return generic