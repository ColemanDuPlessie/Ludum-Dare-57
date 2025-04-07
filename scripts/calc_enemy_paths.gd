extends Node

@export var map: TileMapLayer
var pathing_map # COORDS ARE (Y, X), NOT (X, Y), because width is fixed but height varies!
var spawn_locations # This is a dictionary between tiles (in (X, Y) coords) and spawn probabilities (which sum to spawn_weighting!)
var spawn_weighting
var initial_pathing_map
var null_map

const SPAWN_SOFTMAX_STRENGTH = 2.0
const MIN_SPAWN_CHANCE = 0.01 # If there is less than this chance of enemies spawning in a tile, they won't spawn there at all.
const DIRECTIONS: Array[Vector2] = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

const DOWN = Vector2.RIGHT # This terrible, horrible line of code is a result of pathing_map being in the form (Y, X). DO NOT CHANGE!

var rng = RandomNumberGenerator.new();

func _ready():
	initial_pathing_map = []
	null_map = []
	for i in range(Static.GAME_WIDTH):
		initial_pathing_map.append(abs(i - Static.GAME_WIDTH / 2.0))
		null_map.append(null)
	pathing_map = [initial_pathing_map.duplicate(),]

func get_enemy_spawn_location() -> Vector2:
	var rand = rng.randf_range(0, spawn_weighting)
	var current = 0.0
	for loc in spawn_locations.keys():
		current += spawn_locations[loc]
		if current > rand:
			return loc
	return Vector2(5, 0) # THIS SHOULD NEVER OCCUR

# Returns the unit vector (in DIRECTIONS) that results in the enemy moving towards the surface.
func move_enemy(loc: Vector2, rand: bool=false) -> Vector2i:
	var lookup_idx = get_lookup_corrected_idx(loc.x, loc.y)

	if lookup_idx[0] < 0 or lookup_idx[1] < 0 or lookup_idx[1] >= map.max_generated_depth or lookup_idx[0] >= Static.GAME_WIDTH:
		return Vector2(0, 0) # The enemy is not currently in an open tunnel space...
	else:
		var best = null
		var best_score = 10000
		for dir in DIRECTIONS:
			var new = lookup_idx + dir
			if new[0] < 0 or new[1] < 0 or new[1] >= map.max_generated_depth or new[0] >= Static.GAME_WIDTH:
				continue
			var score = pathing_map[int(new[1])][int(new[0])]
			
			var curdir = dir
			if score != null:
				if score < best_score:
					var temp = best_score
					best_score = score
					score = temp
					
					curdir = best
					best = dir
				var diff = score-best_score
				if curdir == DIRECTIONS[3]:
					continue
				if rand and randf() < pow(0.5, diff):
					best_score = score
					best = curdir
		return best

func sum(arr:Array):
	var result = 0
	for i in arr:
		result+=i
	return result

func get_cell_corrected_idx(x: int, y: int):
	return Vector2(x - floor(Static.GAME_WIDTH / 2.0), y)

func get_lookup_corrected_idx(x: float, y: float):
	return Vector2(floor(x / 16) + floor(Static.GAME_WIDTH / 2.0), floor(y / 16))

func calc_pathing() -> void:
	pathing_map = [initial_pathing_map.duplicate(),]

	spawn_locations = {}

	for i in range(0, map.max_generated_depth):
		pathing_map.append(null_map.duplicate())

	var processing_queue: Array[Vector2] = []
	var processing_queue_pointer = 0
	
	for i in range(Static.GAME_WIDTH):
		processing_queue.append(Vector2(0, i))

	while processing_queue_pointer < len(processing_queue):
		var currently_processing: Vector2 = processing_queue[processing_queue_pointer]

		for dir in DIRECTIONS:
			var new_loc: Vector2 = currently_processing + dir
			
			if new_loc[0] < 0 or new_loc[1] < 0 or new_loc[1] >= Static.GAME_WIDTH or new_loc[0] > map.max_generated_depth:
				continue

			if new_loc in processing_queue:
				continue

			var correct_idx = get_cell_corrected_idx(new_loc[1], new_loc[0])
			var tile_type = map.get_cell(correct_idx.x, correct_idx.y)
			
			if tile_type == Vector2i(-1, -1): # If there is no tile...
				processing_queue.append(new_loc)
				
				pathing_map[new_loc[0]][new_loc[1]] = pathing_map[currently_processing[0]][currently_processing[1]]+1
			elif dir == DOWN and pathing_map[currently_processing[0]][currently_processing[1]] > 0: # If this is a floor tile... DO NOT CHANGE TO VECTOR2.DOWN!
				spawn_locations[Vector2(currently_processing[1], currently_processing[0])] = SPAWN_SOFTMAX_STRENGTH ** currently_processing[0]

		processing_queue_pointer += 1
	
	var spawn_locations_removed = true

	while spawn_locations_removed:
		spawn_locations_removed = false

		spawn_weighting = sum(spawn_locations.values())

		for loc in spawn_locations.keys():
			if spawn_locations[loc] < spawn_weighting * MIN_SPAWN_CHANCE:
				spawn_locations.erase(loc)
				spawn_locations_removed = true
