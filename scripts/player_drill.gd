extends CharacterBody2D

var moving = false
var movement_progress = 0
var movement_direction = Vector2.ZERO
var last_position = Vector2.ZERO

func _ready():
	last_position = global_position

func _physics_process(delta):
	if !moving:
		check_movement_direction()
	
	if moving:
		move(delta)

func check_movement_direction():
	if Input.is_action_pressed("right"):
		movement_direction = Vector2.RIGHT
		moving = true
	
	if Input.is_action_pressed("left"):
		movement_direction = Vector2.LEFT
		moving = true
	
	if Input.is_action_pressed("up"):
		movement_direction = Vector2.UP
		moving = true

	if Input.is_action_pressed("down"):
		movement_direction = Vector2.DOWN
		moving = true

func move(delta):
	look_at(global_position + movement_direction)

	movement_progress += delta

	movement_progress = clampf(movement_progress, 0, 1)

	global_position = last_position + movement_direction * 16 * movement_progress

	if movement_progress == 1:
		last_position = global_position
		moving = false
		movement_progress = 0