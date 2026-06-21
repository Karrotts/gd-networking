class_name ServerItemPanel extends Button

signal server_item_selected()

@onready var server_name_label: Label = $MarginContainer/HBoxContainer/TextContainer/ServerNameLabel
@onready var server_description_label: Label = $MarginContainer/HBoxContainer/TextContainer/ServerDescriptionLabel
@onready var players_label: Label = $MarginContainer/HBoxContainer/StartsContainer/PlayersLabel
@onready var ping_label: Label = $MarginContainer/HBoxContainer/StartsContainer/PingLabel
@onready var server_image: TextureRect = $MarginContainer/HBoxContainer/ServerImage

var network_settings: NetworkSettings	

func set_info(server_info: ServerSettings, connected_users: int, ping_ms: int) -> void:
	server_image.modulate = Color(1, 1, 1, 1)
	server_name_label.text = server_info.server_name
	server_description_label.text = server_info.server_description
	players_label.text = "%d/%d" % [connected_users, server_info.max_allowed_players]
	ping_label.text = "%d ms" % ping_ms
