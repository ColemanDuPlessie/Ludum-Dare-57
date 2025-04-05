extends StaticBody2D

const MOVE_SPEED = 1.5 # In tiles/second

var pathfinding: Node

var moving = false
var movement_progress = 0
var movement_direction = Vector2.ZERO
var last_position = Vector2.ZERO
var grid_aligned_position = Vector2.ZERO

func _global_to_grid_coords():
	grid_aligned_position = Vector2(int((global_position[0]-8)/16)+9, int((global_position[1]-8)/16)+3)

func _set_grid_coords(loc: Vector2):
	grid_aligned_position = loc
	global_position = Vector2((loc[0]-9)*16+8, (loc[1]-3)*16+8)

func _ready():
	last_position = global_position

func _physics_process(delta):
	if !moving: # TODO also add a state for "digging out of the ground for a second"
		get_movement_direction(delta)
	
	if moving:
		move(delta)

func get_movement_direction(delta):
	movement_direction = pathfinding.move_enemy(grid_aligned_position)
	moving = true


func move(delta):
	movement_progress += delta*MOVE_SPEED

	movement_progress = clampf(movement_progress, 0, 1)
	
	var movement_dist = movement_direction * 16 * movement_progress
	movement_dist = Vector2(int(movement_dist[0]), int(movement_dist[1]))

	global_position = last_position + movement_dist

	if movement_progress == 1:
		grid_aligned_position += movement_direction
		last_position = global_position
		moving = false
		movement_progress = 0
