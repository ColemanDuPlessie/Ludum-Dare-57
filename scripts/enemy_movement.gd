extends StaticBody2D

const MOVE_SPEED = 1 # In tiles/second

var pathfinding: Node

var moving = false
var movement_progress = 0
var movement_direction = Vector2.ZERO
var last_position = Vector2.ZERO

func _ready():
	last_position = global_position

func _physics_process(delta):
	if !moving: # TODO also add a state for "digging out of the ground for a second"
		get_movement_direction(delta)
	
	if moving:
		move(delta)

func get_movement_direction(delta):
	movement_direction = pathfinding.move_enemy(global_position)
	moving = true

func move(delta):
	movement_progress += delta * MOVE_SPEED

	movement_progress = clampf(movement_progress, 0, 1)
	
	global_position = last_position + movement_direction * 16 * movement_progress

	if movement_progress == 1:
		last_position = global_position
		moving = false
		movement_progress = 0
