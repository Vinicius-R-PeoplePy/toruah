extends Node

var customization_data = {}

const SAVE_PATH = "user://customization_data.save"

# Save customization data to a file
func save_customization(key, color):
	customization_data[key] = color
	_save_to_file()

# Get customization data from the dictionary
func get_customization():
	return customization_data

# Save the customization data to a file
func _save_to_file():
	var file = FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file:
		file.store_var(customization_data)
		file.close()
	else:
		print("Error opening file for writing: %s" % SAVE_PATH)

# Load the customization data from a file
func _load_from_file():
	var file = FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file:
		customization_data = file.get_var()
		file.close()
	else:
		print("Error opening file for reading: %s" % SAVE_PATH)
	

# Call this function when the node is added to the scene tree
func _ready():
	_load_from_file()
