extends StaticBody2D

@export var pathfinding: Node
var moving = false
var movement_progress = 0
var movement_direction = Vector2.ZERO
var last_position = Vector2.ZERO
var grid_aligned_position = Vector2.ZERO

func _global_to_grid_coords():
	grid_aligned_position = Vector2(int((global_position[0]-8)/16)+9, int((global_position[1]-8)/16)+3)

func _ready():
	_global_to_grid_coords()
	last_position = global_position

func _physics_process(delta):
	if !moving:
		get_movement_direction(delta)
	
	if moving:
		move(delta)

func get_movement_direction(delta):
	print(grid_aligned_position)
	movement_direction = pathfinding.move_enemy(grid_aligned_position)
	moving = true
	# TODO maybe add back in look_at(global_position + movement_direction)


func move(delta):
	movement_progress += delta

	movement_progress = clampf(movement_progress, 0, 1)

	global_position = last_position + movement_direction * 16 * movement_progress

	if movement_progress == 1:
		grid_aligned_position += movement_direction
		last_position = global_position
		moving = false
		movement_progress = 0
