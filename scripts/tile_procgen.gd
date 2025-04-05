extends TileMapLayer

const GAME_WIDTH = 18
const HEIGHT_OFFSET = 3

const CORRECTION_VECTOR = Vector2(GAME_WIDTH/2, HEIGHT_OFFSET) # Add this vector to a tile's coordinates to get its 0-indexed coordinates.

const DIRT_TILE = Vector2i(16, 1)
const GOLD_TILE = Vector2i(17, 1)
const GEMS_TILE = Vector2i(16, 2)
const OBSIDIAN_TILE = Vector2i(16, 5)

var rng = RandomNumberGenerator.new();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	for i in range(3): # Generate a little bit of the map ahead of time.
		generate_new()
	pass # Replace with function body.

var max_generated_depth = 7 # TODO temp RESET THIS TO 0

func get_cell_corrected_idx(loc: Vector2) -> Vector2i:
	return get_cell_atlas_coords(loc - CORRECTION_VECTOR)

func get_cell(x: int, y: int) -> Vector2i:
	return get_cell_atlas_coords(Vector2i(x, y))

func destroy_tile(x: int, y:int) -> Vector2i:
	var destroyed = get_cell(x, y)
	if destroyed == GOLD_TILE:
		get_parent().increment_gold(1)
	elif destroyed == GEMS_TILE:
		get_parent().increment_gems(1)
	erase_cell(Vector2i(x, y))
	return destroyed

# Call if the player is nearing the end of the screen
func generate_new() -> void: # TODO this is the barest of placeholders, there are so many fun things we could do here
	max_generated_depth += 1
	for x_pos in range(-GAME_WIDTH/2, GAME_WIDTH/2):
		var tile_pos = Vector2i(x_pos, max_generated_depth-HEIGHT_OFFSET)

		print(tile_pos)

		if rng.randi_range(1, 20) == 1:
			set_cell(tile_pos, 0, GOLD_TILE)
		elif rng.randi_range(1, 40) == 1:
			set_cell(tile_pos, 0, GEMS_TILE)
		else:
			set_cell(tile_pos, 0, DIRT_TILE)
