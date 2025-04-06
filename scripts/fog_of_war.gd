extends TileMapLayer

const DUPLO_LOC_DELTAS = [Vector2(0, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(-1, -1)]

var fading_tiles = {} # Dict of Vector2is corresponding to tiles and timers for how long until they cease to exist.
const FADE_TIMES = [0.8, 0.6, 0.45, 0.3, 0.15]

func _on_drill_spawned(player):
	player.moving_to_tile.connect(_on_player_moving_to_tile)
	
func _on_player_moving_to_tile(location):
	reveal_from(floor((location - Vector2.ONE * 8) / 16))

func check_duplo_revealed(loc: Vector2) -> bool:
	var true_loc = floor(loc/16)
	for delta in DUPLO_LOC_DELTAS:
		if get_cell_atlas_coords(true_loc+delta) != Vector2i(-1, -1):
			return false
	return true

func begin_fading_cell(loc: Vector2) -> void:
	if not fading_tiles.has(loc):
		fading_tiles[loc] = FADE_TIMES[Static.PLAYER_RADAR_LEVEL]

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return fading_tiles.has(Vector2(coords))

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.modulate = Color(1, 1, 1, fading_tiles[Vector2(coords)]/FADE_TIMES[Static.PLAYER_RADAR_LEVEL])

func _process(delta: float) -> void:
	if len(fading_tiles) > 0:
		notify_runtime_tile_data_update()
	for tile in fading_tiles.keys():
		var remaining = fading_tiles[tile] - delta
		if remaining <= 0:
			erase_cell(tile)
			fading_tiles.erase(tile)
		else:
			fading_tiles[tile] = remaining

func reveal_from(loc: Vector2) -> void:
	var min_x = loc.x - floor(sqrt(Static.MAX_REVEAL_RANGE))
	var max_x = loc.x + floor(sqrt(Static.MAX_REVEAL_RANGE))
	var min_y = loc.y - floor(sqrt(Static.MAX_REVEAL_RANGE))
	var max_y = loc.y + floor(sqrt(Static.MAX_REVEAL_RANGE))
	
	for x in range(min_x, max_x+1): # TODO this is inefficient, but it's only a constant-time-complexity slowdown, so I think it's fine
		for y in range(min_y, max_y+1):
			if (x-loc.x)**2 + (y-loc.y)**2 <= Static.MAX_REVEAL_RANGE:
				if get_cell_atlas_coords(Vector2(x, y)) != Vector2i(-1, -1):
					begin_fading_cell(Vector2(x, y))
