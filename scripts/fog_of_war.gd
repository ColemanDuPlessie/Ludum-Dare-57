extends TileMapLayer

const GAME_WIDTH = 18
const HEIGHT_OFFSET = 3

const CORRECTION_VECTOR = Vector2(GAME_WIDTH/2, HEIGHT_OFFSET) # Add this vector to a tile's coordinates to get its 0-indexed coordinates.


var MAX_REVEAL_RANGE = 5 # The player can see sqrt(MAX_REVEAL_RANGE) units away in any direction. We can sell upgrades for this.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_drill_spawned(player):
	player.moving_to_tile.connect(_on_player_moving_to_tile)
	
func _on_player_moving_to_tile(location):
	reveal_from(location)

func get_cell_corrected_idx(loc: Vector2) -> Vector2i:
	return get_cell_atlas_coords(loc - CORRECTION_VECTOR)

func corrected_idx_to_useful_idx(loc: Vector2) -> Vector2:
	return loc - CORRECTION_VECTOR

func reveal_from(loc: Vector2) -> void:
	var true_loc = corrected_idx_to_useful_idx(loc)
	var min_x = true_loc[0] - floor(sqrt(MAX_REVEAL_RANGE))
	var max_x = true_loc[0] + floor(sqrt(MAX_REVEAL_RANGE))
	var min_y = true_loc[1] - floor(sqrt(MAX_REVEAL_RANGE))
	var max_y = true_loc[1] + floor(sqrt(MAX_REVEAL_RANGE))
	
	for x in range(min_x, max_x+1): # TODO this is inefficient, but it's only a constant-time-complexity slowdown, so I think it's fine
		for y in range(min_y, max_y+1):
			if (x-true_loc[0])**2 + (y-true_loc[1])**2 <= MAX_REVEAL_RANGE:
				if get_cell_atlas_coords(Vector2(x, y)) != null:
					erase_cell(Vector2(x, y)) # TODO we can make this fade away instead of just pop out of existence; it'll look much cooler.
