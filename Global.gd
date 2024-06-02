extends Node

var player_instance = null

func _ready():
	player_instance = create_player_instance()
	load_player_customization()

func create_player_instance():
	if not player_instance:
		var player_scene = preload("res://player.tscn")
		player_instance = player_scene.instantiate()
		add_child(player_instance)
	return player_instance
	
func load_player_customization():
	var customization_data = CustomizationData.get_customization()
	for key in customization_data.keys():
		var color = Color(customization_data[key])
		update_player_appearance(key, color)

func update_player_appearance(key, color):
	match key:
		"cor_de_pele":
			player_instance.get_node("Node2D/skin").modulate = color
		"blusa":
			player_instance.get_node("Node2D/blusa").modulate = color
		"olhos":
			player_instance.get_node("Node2D/olhos").modulate = color
		"cabelo":
			player_instance.get_node("Node2D/cabelo").modulate = color
		"calca":
			player_instance.get_node("Node2D/calca").modulate = color
		"sapatos":
			for shoe in player_instance.get_node("Node2D/sapatos").get_children():
				shoe.modulate = color
