class_name ServerBrowser extends Control

@export var server_item_panel: PackedScene

@onready var server_items_container: VBoxContainer = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/ServerItemsContainer

func _ready() -> void:
	var item: ServerItemPanel = server_item_panel.instantiate() as ServerItemPanel
	server_items_container.add_child(item)
	item.set_info()
