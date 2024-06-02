extends Node2D

class_name level

var player_scene = preload("res://player.tscn")
var player_instance
var is_player_in_Bank_area = false  # Flag to track if the player is in the Bank area

func _ready():
	player_instance = player_scene.instantiate()
	add_child(player_instance)

	load_player_customization()

func load_player_customization():
	var customization_data = CustomizationData.get_customization()
	for key in customization_data.keys():
		var color = Color(customization_data[key])
		update_player_appearance(key, color)

func update_player_appearance(key, color):
	match key:
		"cor_de_pele":
			player_instance.get_node("/root/level/player/Node2D/skin").modulate = color
		"blusa":
			player_instance.get_node("/root/level/player/Node2D/blusa").modulate = color
		"olhos":
			player_instance.get_node("/root/level/player/Node2D/olhos").modulate = color
		"cabelo":
			player_instance.get_node("/root/level/player/Node2D/cabelo").modulate = color
		"calca":
			player_instance.get_node("/root/level/player/Node2D/calca").modulate = color
		"sapatos":
			for shoe in player_instance.get_node("/root/level/player/Node2D/sapatos").get_children():
				shoe.modulate = color

func _process(delta):
	if is_player_in_Bank_area and Input.is_action_just_pressed("entrar"):
		print("BOTÃO PRESSIONADO")
		get_tree().change_scene_to_file("res://bank.tscn") and get_node(player_scene)

func _on_Bank_area_body_entered(body):
	if body.is_in_group("player"):
		print("Está na área")
		$/root/level/BANK/entrar_banco.show()
		is_player_in_Bank_area = true

func _on_Bank_area_body_exited(body):
	if body.is_in_group("player"):
		print("SAIU DA ÁREA")
		$/root/level/BANK/entrar_banco.hide()
		is_player_in_Bank_area = false
