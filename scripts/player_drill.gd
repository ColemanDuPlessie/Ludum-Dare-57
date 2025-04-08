extends CharacterBody2D

signal moving_to_tile(location)

var MOVE_SPEED = [3.75, 4.75, 5.75, 6.75, 7.75]
const DRILL_SPEED = [2.5, 3, 3.75, 4.5, 5.5]

var fuel_remaining = Static.MAX_FUEL

var moving = false
var movement_progress = 0
var movement_direction = Vector2.ZERO
var last_position = Vector2.ZERO

var destruction_progress = 0

var move_cooldown = 0.2

@onready var sprite = get_node("Sprite2D")
@onready var drill = get_node("Sprite2D/Drill")
@onready var drill_noise = get_node("Drill")
@onready var drill_noise_hard = get_node("DrillHard")

const FLASH_COOLDOWN = 0.25
var flashing = false
var time_to_flash = 0.0

func _ready():
	last_position = global_position
	drill_noise.volume_linear = 0.0
	drill_noise_hard.volume_linear = 0.0

func _physics_process(delta):
	move_cooldown -= delta
	
	drill_noise.volume_linear = 0.0
	drill_noise_hard.volume_linear = 0.0
	sprite.speed_scale = 0.5
	drill.speed_scale = 0.5
	drill.modulate = Color(1, 1, 1)

	if !moving:
		check_movement_direction(delta)
	
	if moving:
		sprite.speed_scale = MOVE_SPEED[Static.PLAYER_DRILL_LEVEL]/2
		move(delta)

func check_movement_direction(delta):
	if move_cooldown > 0:
		return

	if Input.is_action_pressed("right"):
		if movement_direction != Vector2.RIGHT:
			destruction_progress = 0

		movement_direction = Vector2.RIGHT
		sprite.flip_v = false
		moving = true
	elif Input.is_action_pressed("left"):
		if movement_direction != Vector2.LEFT:
			destruction_progress = 0

		movement_direction = Vector2.LEFT
		sprite.flip_v = false
		moving = true
	elif Input.is_action_pressed("up"):
		if movement_direction != Vector2.UP:
			destruction_progress = 0

		movement_direction = Vector2.UP
		sprite.flip_v = false
		moving = true
	elif Input.is_action_pressed("down"):
		if movement_direction != Vector2.DOWN:
			destruction_progress = 0

		movement_direction = Vector2.DOWN
		sprite.flip_v = true
		moving = true
	else:
		destruction_progress = 0

		movement_direction = Vector2.ZERO

	if moving:
		sprite.look_at(sprite.global_position + movement_direction)

		if movement_direction == Vector2.LEFT:
			sprite.rotation = 0

			sprite.scale = Vector2(-1, 1)
		else:
			sprite.scale = Vector2(1, 1)

	if moving:
		var params = PhysicsShapeQueryParameters2D.new()

		var shape = RectangleShape2D.new()
		shape.size = Vector2(8, 8)
		params.shape = shape

		params.transform.origin = global_position + movement_direction * 16
		params.collide_with_bodies = true
		params.collision_mask = 1

		var results = get_world_2d().direct_space_state.intersect_shape(params)

		for result in results:
			if result.collider is not TileMapLayer: # Ran into building
				moving = false
				break

		if len(results) > 0 && moving:
			moving = false

			var tile_procgen = results[0].collider
			var location = floor(global_position / 16 + movement_direction)
			var tile = tile_procgen.get_cell(location.x, location.y)
			var fuel_cost = Static.FUEL_COSTS[tile][Static.PLAYER_DRILL_LEVEL]

			if fuel_cost <= fuel_remaining:
				flashing = false
				time_to_flash = 0.0
				drill_noise.volume_linear = 0.3
				drill.speed_scale = 1.0
				
				destruction_progress += delta * DRILL_SPEED[Static.PLAYER_DRILL_LEVEL] / sqrt(Static.FUEL_COSTS[tile][Static.PLAYER_DRILL_LEVEL]) * 2

				if destruction_progress >= 1:
					destruction_progress = 0

					fuel_remaining -= fuel_cost

					update_fuel_gague()
					
					tile_procgen.destroy_tile(location.x, location.y)

					if Static.tower_menu.size > 0.0 and abs(location.x*16-Static.tower_menu.global_position.x) <= 12 and abs(location.y*16-Static.tower_menu.global_position.y) <= 12:
						print(location)
						print(Static.tower_menu.global_position)
						Static.tower_menu.disappear()
					
					Static.camera.shake(0.5)
			else:
				drill_noise_hard.volume_linear = 0.3
				drill.speed_scale = 2.0
				time_to_flash -= delta
				if time_to_flash <= 0.0:
					time_to_flash = FLASH_COOLDOWN
					flashing = not flashing
				if flashing:
					drill.modulate = Color(1, 0.2, 0.2)
						
		else:
			flashing = false
			time_to_flash = 0.0
		
	if moving && movement_direction == Vector2.UP && global_position.y == 8:
		moving = false

	if moving:
		var target_pos = global_position + movement_direction * 16
		
		moving_to_tile.emit(target_pos)

func update_fuel_gague():
	Static.fuel_meter.set_height(float(fuel_remaining)/Static.MAX_FUEL)

func update_radar_power():
	Static.MAX_REVEAL_RANGE = Static.RADAR_POWERS[Static.PLAYER_RADAR_LEVEL]
	moving_to_tile.emit(global_position)

func move(delta):
	movement_progress += delta * MOVE_SPEED[Static.PLAYER_DRILL_LEVEL]

	movement_progress = clampf(movement_progress, 0, 1)

	var movement_dist = movement_direction * 16 * movement_progress
	movement_dist = Vector2(int(movement_dist[0]), int(movement_dist[1]))

	global_position = last_position + movement_dist

	if movement_progress == 1:
		last_position = global_position
		moving = false
		movement_progress = 0

		Static.deepest = max(floor(global_position.y / 16), Static.deepest)
