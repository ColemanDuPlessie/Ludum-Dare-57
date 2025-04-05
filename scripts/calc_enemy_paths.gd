extends Node

@export var map: TileMapLayer
var pathing_map # COORDS ARE (Y, X), NOT (X, Y), because width is fixed but height varies!
var initial_pathing_map
var null_map

const DIRECTIONS = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]

func _ready():
	initial_pathing_map = []
	null_map = []
	for i in range(map.GAME_WIDTH):
		initial_pathing_map.append(0)
		null_map.append(null)
	pathing_map = [initial_pathing_map.duplicate(),]
	calc_pathing()

# Returns the unit vector (in DIRECTIONS) that results in the enemy moving towards the surface.
func move_enemy(loc: Vector2) -> Vector2:
	if loc[0] < 0 or loc[1] < 0 or loc[0] > map.max_generated_depth or loc[1] > map.GAME_WIDTH or pathing_map[loc[1]][loc[0]] == null:
		return Vector2(0, 0) # The enemy is not currently in an open tunnel space...
	else:
		var best = null
		var best_score = null
		for dir in DIRECTIONS:
			var new = loc + dir
			var score = pathing_map[new[1]][new[0]]
			if score != null and (best_score == null or score < best_score):
				best_score = score
				best = dir
		return best

func calc_pathing() -> void:
	pathing_map = [initial_pathing_map.duplicate(),]
	for i in range(1, map.max_generated_depth):
		pathing_map.append(null_map.duplicate())
	var processing_queue = []
	var processing_queue_pointer = 0
	for i in range(map.GAME_WIDTH):
		processing_queue.append(Vector2(0, i))
	while processing_queue_pointer < len(processing_queue):
		var currently_processing = processing_queue[processing_queue_pointer]
		for dir in DIRECTIONS:
			var new_loc = currently_processing + dir
			if new_loc[0] < 0 or new_loc[1] < 0 or new_loc[1] >= map.GAME_WIDTH or new_loc[0] > map.max_generated_depth:
				continue
			elif new_loc in processing_queue:
				continue
			else:
				var tile_type = map.get_cell_corrected_idx(Vector2(new_loc[1], new_loc[0]))
				if tile_type != map.DIRT_TILE and tile_type != map.GOLD_TILE and tile_type != map.GEMS_TILE and tile_type != map.OBSIDIAN_TILE: # If there is no tile...
					processing_queue.append(new_loc)
					pathing_map[new_loc[0]][new_loc[1]] = pathing_map[currently_processing[0]][currently_processing[1]]+1
		processing_queue_pointer += 1
	print(pathing_map) # TODO this is for debugging
