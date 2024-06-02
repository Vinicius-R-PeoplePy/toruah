extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@export var player_saldo: int = 100
var transaction_history = []
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var melecas = $/root/Global/player/Camera2D/melecas
@onready var player = preload("res://player.tscn")
var direction = Vector2(0, 0)

func _ready():
	update_melecas_label()
	load_saldo_from_save_data()
	#handle_input_event()

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset the vertical velocity when on the floor

	# Jumping
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	if Input.is_action_pressed("esquerda"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("direita"):
		velocity.x = SPEED
	else:
		velocity.x = 0  # Stop horizontal movement if no input is detected

	# Apply the velocity to the character
	move_and_slide()

func handle_input_event():
	if Input.is_action_just_pressed("entrar"):
		print("BOTÃO PRESSIONADO")
		if $/root/BANK/entrar_banco_area.get_overlapping_bodies().has(self):
			get_tree().change_scene_to_file("res://bank.tscn")

func update_and_save_saldo(amount):
	# Subtract the amount from player's saldo
	player_saldo -= amount
	save_saldo_to_save_data()
	update_melecas_label()

func update_melecas_label():
	melecas.text = "Melecas: " + str(player_saldo)

func save_saldo_to_save_data():
	var file = FileAccess.open("user://player_data5.sav", FileAccess.WRITE)
	if file:
		file.store_var(player_saldo)
		file.close()

func load_saldo_from_save_data():
	var file = FileAccess.open("user://player_data5.sav", FileAccess.READ)
	if file:
		player_saldo = file.get_var()
		file.close()		

func get_saldo() -> int:
	return player_saldo

func set_saldo(value: int) -> void:
	player_saldo = value
	update_melecas_label()
