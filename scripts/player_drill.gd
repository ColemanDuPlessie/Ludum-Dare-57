extends CharacterBody2D

var moving = false
var movement_progress = 0
var movement_direction = Vector2(0, 0)

func _physics_process(delta):
	if

func check_movement_direction():
	if Input.is_action_pressed("right"):
		movement_direction = Vector2.RIGHT
		moving = true
		movement_progress = 0
	
	if Input.is_action_pressed("left"):
		movement_direction = Vector2.LEFT
		moving = true
		movement_progress = 0
	
	if Input.is_action_pressed("up"):
		movement_direction = Vector2.UP
		moving = true
		movement_progress = 0

	if Input.is_action_pressed("down"):
		movement_direction = Vector2.DOWN
		moving = true
		movement_progress = 0
