extends CharacterBody2D

@export var FOG_OF_WAR: TileMapLayer
@export var MAIN: Node2D # TODO is this idiomatic???

var fuel_remaining = 50 # TODO add a fuel meter to the UIOverlay
var MAX_FUEL = 50

var moving = false
var movement_progress = 0
var movement_direction = Vector2.ZERO
var last_position = Vector2.ZERO

var destruction_progress = 0

func _ready():
	last_position = global_position

	# Just for debug purposes right now
	# TODO commented out to work on mining. Add it back in if you need.
	# var game_manager = get_parent().get_parent().get_node("GameManager")
	# if game_manager.current_player == null:
	# 	game_manager.current_player = self

func _physics_process(delta):
	if !moving:
		check_movement_direction(delta)
	
	if moving:
		move(delta)

func check_movement_direction(delta):
	if Input.is_action_pressed("right"):
		if movement_direction != Vector2.RIGHT:
			destruction_progress = 0

		movement_direction = Vector2.RIGHT
		moving = true
	elif Input.is_action_pressed("left"):
		if movement_direction != Vector2.LEFT:
			destruction_progress = 0

		movement_direction = Vector2.LEFT
		moving = true
	elif Input.is_action_pressed("up"):
		if movement_direction != Vector2.UP:
			destruction_progress = 0

		movement_direction = Vector2.UP
		moving = true
	elif Input.is_action_pressed("down"):
		if movement_direction != Vector2.DOWN:
			destruction_progress = 0

		movement_direction = Vector2.DOWN
		moving = true
	else:
		destruction_progress = 0

		movement_direction = Vector2.ZERO

	if moving:
		look_at(global_position + movement_direction)

	if moving:
		var params = PhysicsShapeQueryParameters2D.new()

		var shape = RectangleShape2D.new()
		shape.size = Vector2(8, 8)
		params.shape = shape

		params.transform.origin = global_position + movement_direction * 16
		params.collide_with_bodies = true
		params.collision_mask = 1

		var results = get_world_2d().direct_space_state.intersect_shape(params)

		if len(results) > 0:
			moving = false

			destruction_progress += delta

			if destruction_progress >= 1:
				destruction_progress = 0

				var tile_procgen = results[0].collider

				var location = floor(global_position / 16 + movement_direction)
				var destroyed = tile_procgen.get_cell(location.x, location.y)
				var fuel_cost = tile_procgen.FUEL_COSTS[destroyed]
				
				if fuel_cost <= fuel_remaining:
					fuel_remaining -= fuel_cost
					tile_procgen.destroy_tile(location.x, location.y)
		
		if moving == true:
			var target_pos = _global_to_grid_coords()+movement_direction
			FOG_OF_WAR.reveal_from(target_pos)

func _global_to_grid_coords():
	return Vector2(int((global_position[0]-8)/16)+9, int((global_position[1]-8)/16)+3)

func move(delta):
	movement_progress += delta

	movement_progress = clampf(movement_progress, 0, 1)

	var movement_dist = movement_direction * 16 * movement_progress
	movement_dist = Vector2(int(movement_dist[0]), int(movement_dist[1]))

	global_position = last_position + movement_dist

	if movement_progress == 1:
		if _global_to_grid_coords()[1] <= 0:
			MAIN.show_shop()
		else:
			MAIN.hide_shop()
		last_position = global_position
		moving = false
		movement_progress = 0
