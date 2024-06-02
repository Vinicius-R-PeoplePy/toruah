extends Node2D

class_name bank 


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_caixa_1_area_body_entered(body):
	if body.is_in_group("player"):
		$/root/level/Control.show()

func _on_caixa_1_area_body_exited(body):
	if body.is_in_group("player"):
		$/root/level/Control.hide()
