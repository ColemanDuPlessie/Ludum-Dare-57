extends TileMapLayer

var MAX_REVEAL_RANGE = 5 # The player can see sqrt(MAX_REVEAL_RANGE) units away in any direction. We can sell upgrades for this.

func _on_drill_spawned(player):
	player.moving_to_tile.connect(_on_player_moving_to_tile)
	
func _on_player_moving_to_tile(location):
	reveal_from(floor((location - Vector2.ONE * 8) / 16))

func reveal_from(loc: Vector2) -> void:
	var min_x = loc.x - floor(sqrt(MAX_REVEAL_RANGE))
	var max_x = loc.x + floor(sqrt(MAX_REVEAL_RANGE))
	var min_y = loc.y - floor(sqrt(MAX_REVEAL_RANGE))
	var max_y = loc.y + floor(sqrt(MAX_REVEAL_RANGE))
	
	for x in range(min_x, max_x+1): # TODO this is inefficient, but it's only a constant-time-complexity slowdown, so I think it's fine
		for y in range(min_y, max_y+1):
			if (x-loc.x)**2 + (y-loc.y)**2 <= MAX_REVEAL_RANGE:
				if get_cell_atlas_coords(Vector2(x, y)) != null:
					erase_cell(Vector2(x, y)) # TODO we can make this fade away instead of just pop out of existence; it'll look much cooler.
