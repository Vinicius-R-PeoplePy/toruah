extends CharacterBody2D 


const SPEED = 900.0
const JUMP_VELOCITY = -400.0
@export var player_saldo : int = 100
var transaction_history = []
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var melecas = $/root/level/player/Camera2D/melecas
var File = FileAccess# Create a new File object

func _ready():
	update_melecas_label()
	load_saldo_from_save_data()
	#handle_input_event()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta 
		
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction = Vector2(
		Input.get_axis("esquerda", "direita"),
		Input.get_axis("cima", "baixo")
	)
	
	if direction != Vector2.ZERO: 
		direction = direction.normalized()
		
	velocity.x = direction.x * SPEED 
	velocity.y = direction.y * SPEED 
	
	move_and_slide()

func update_and_save_saldo(amount):
	player_saldo -= amount
	save_saldo_to_save_data()
	update_melecas_label()
	
func update_melecas_label():
	melecas.text = "Melecas: " + str(player_saldo)

func save_saldo_to_save_data():
	var file = File.open("user://player_data3.sav", File.WRITE)
	if file:
		file.store_var(player_saldo)
		file.close()

func load_saldo_from_save_data():
	var file = File.open("user://player_data3.sav", File.READ)
	if file:
		player_saldo = file.get_var()
		file.close()		

func get_saldo() -> int:
	return player_saldo

func set_saldo(value: int) -> void:
	player_saldo = value
	update_melecas_label()
