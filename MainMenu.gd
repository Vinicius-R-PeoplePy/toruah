extends Control

var File = FileAccess

@onready var color_picker_buttons = {
	"cor_de_pele": $/root/Control/Main/Node2D/ColorPickerButtonCorDePele,
	"cabelo": $/root/Control/Main/Node2D/ColorPickerButtonCabelo,
	"blusa": $/root/Control/Main/Node2D/ColorPickerButtonBlusa,
	"olhos": $/root/Control/Main/Node2D/ColorPickerButtonOlhos,
	"calca": $/root/Control/Main/Node2D/ColorPickerButtonCalca,
	"sapatos": $/root/Control/Main/Node2D/ColorPickerButtonSapatos,
}

@onready var modulate_targets = {
	"cor_de_pele": $/root/Control/Main/player/CorDePele,
	"cabelo": $/root/Control/Main/player/cabelo,
	"blusa": $/root/Control/Main/player/blusa,
	"olhos": $/root/Control/Main/player/olhos,
	"calca": $/root/Control/Main/player/calca,
	"sapatos": [$/root/Control/Main/player/sapatos/sapato1, $/root/Control/Main/player/sapatos/sapato2],
}

@onready var save_button = $save
@onready var start_button = $start
var player_scene = preload("res://player.tscn")

func _ready():
	print(get_tree().current_scene)
	for key in color_picker_buttons.keys():
		var button = color_picker_buttons[key]
		print(key)
		button.connect("color_changed", Callable(self, "_on_color_changed").bind(key))
	
	save_button.connect("pressed", Callable(self, "save_settings"))
	start_button.connect("pressed", Callable(self, "on_start_button_pressed"))

	# Automatically load settings when the scene is loaded
	load_settings()

	# Load the player scene and instantiate it
	print(get_tree().get_root().get_children())
	#get_tree().get_root().add_child(player_scene)





func _on_color_changed(color, key):
	print("Color changed for:", key)
	if key in modulate_targets:
		var target = modulate_targets[key]
		print("Target node:", target)
		# Rest of your code
		if key == "sapatos":
			for sapato in target:
				sapato.modulate = color
		else:
			target.modulate = color
	
	# Save the customization data to the singleton
	CustomizationData.save_customization(key, color)

func save_settings():
	var save_data = {}
	for key in color_picker_buttons.keys():
		if key in modulate_targets:
			var target = modulate_targets[key]
			if key == "sapatos":
				save_data[key] = str(target[0].modulate)  # Assuming both shoes have the same color
			else:
				save_data[key] = str(target.modulate)
	
	var file = File.open("user://settings.json", File.WRITE)
	if file:
		var json_instance = JSON.new()
		file.store_string(json_instance.stringify(save_data))
		file.close()
	else:
		print("Failed to open file for writing.")

func load_settings():
	var file = File.open("user://settings.json", File.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json_instance = JSON.new()
		var parse_result = json_instance.parse(json_text)
		if parse_result == OK:
			var save_data = json_instance.get_data()
			if save_data != null:
				for key in save_data.keys():
					var color = Color(save_data[key])
					_on_color_changed(color, key)
			else:
				print("Error: Parsed data is null.")
		else:
			print("Error parsing JSON:", parse_result)
	else:
		print("Failed to open file for reading.")

func on_start_button_pressed():
	save_settings()
	get_tree().change_scene_to_file("res://level1.tscn")
