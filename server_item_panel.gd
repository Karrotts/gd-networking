class_name ServerItemPanel extends Button

signal server_item_selected()

@onready var server_name_label: Label = $MarginContainer/HBoxContainer/TextContainer/ServerNameLabel
@onready var server_description_label: Label = $MarginContainer/HBoxContainer/TextContainer/ServerDescriptionLabel
@onready var players_label: Label = $MarginContainer/HBoxContainer/StartsContainer/PlayersLabel
@onready var ping_label: Label = $MarginContainer/HBoxContainer/StartsContainer/PingLabel

func _ready() -> void:
	pass
	

func set_info() -> void:
	server_name_label.text = "Walters Watery Walnuts"
	server_description_label.text = "UWU"
	players_label.text = "0/69"
	ping_label.text = "69 ms"
