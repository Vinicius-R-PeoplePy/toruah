extends Node2D

# States
enum State { IDLE, MOVING, DIALOGUE }

# Preload the dialogue resource
var dialogue_resource = preload("res://npc1.dialogue")

@onready var dialogo_area = $DialogoNpc1
@onready var character_body = $/root/level/TileMap/npc1/CharacterBody2D
@onready var animated_sprite = $AnimatedSprite2D

var state = State.IDLE
var move_range = 100
var direction = Vector2.RIGHT
var target_position = Vector2.ZERO

var idle_time = 1.0  # Time to stay idle before moving
var idle_timer = 0.0

func _ready():
	# Connect the body_entered signal to the _on_DialogoNpc1_body_entered function
	dialogo_area.connect("body_entered", Callable(self, "_on_DialogoNpc1_body_entered"))
	dialogo_area.connect("body_exited", Callable(self, "_on_DialogoNpc1_body_exited"))
	set_target_position()
	state = State.MOVING

func _process(delta):
	if state == State.MOVING:
		move_npc(delta)
	elif state == State.IDLE:
		idle_timer -= delta
		animated_sprite.play("idle")
		if idle_timer <= 0:
			set_target_position()
			state = State.MOVING

func set_target_position():
	# Randomly choose a direction and set a target position within the move range
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	target_position = global_position + direction * move_range

func move_npc(delta):
	var distance_to_target = global_position.distance_to(target_position)
	if distance_to_target < 10:
		state = State.IDLE
		idle_timer = idle_time
		return

	# Calculate the movement towards the target position
	var velocity = direction * 50  # Adjust the speed as needed
	global_position += velocity * delta
	update_animation()

func update_animation():
	if direction.x > 0:
		animated_sprite.play("right")
	elif direction.x < 0:
		animated_sprite.play("left")
	elif direction.y > 0:
		animated_sprite.play("down")
	elif direction.y < 0:
		animated_sprite.play("up")

func _on_DialogoNpc1_body_entered(body):
	if body.is_in_group("player"):
		start_dialogue()

func _on_DialogoNpc1_body_exited(body):
	if body.is_in_group("player"):
		end_dialogue()

func start_dialogue():
	state = State.DIALOGUE
	animated_sprite.play("idle")
	DialogueManager.show_dialogue_balloon(dialogue_resource)  # Replace 'show' with the correct method name from your plugin

func end_dialogue():
	# Resume moving after dialogue ends
	set_target_position()
	state = State.MOVING
