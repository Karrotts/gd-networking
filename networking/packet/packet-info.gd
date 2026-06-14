class_name PacketInfo extends Node

var type: int # always the first byte of a packet
var flag: int

func encode() -> PackedByteArray:
	var data: PackedByteArray
	data.resize(1)
	data.encode_u8(0, type)
	return data
	
	
func decode(packet: PackedByteArray) -> void:
	type = packet.decode_u8(0)
	

func broadcast(server: ENetConnection, channel: int = 0) ->  void:
	server.broadcast(channel, encode(), flag)
	

func send(peer: ENetPacketPeer, channel: int = 0) -> void:
	peer.send(channel, encode(), flag)
