extends TileMapLayer

@export var FOG_OF_WAR: TileMapLayer
const FOG_TILE = Vector2i(19, 1)
@export var BACKGROUND: TileMapLayer
const BACKGROUND_TILE = Vector2i(19, 3)

const DUPLO_LOC_DELTAS = [Vector2(0, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(-1, -1)]

var rng = RandomNumberGenerator.new()
var max_generated_depth = -10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	
	while max_generated_depth < 7:
		generate_new()

func _on_drill_spawned(player):
	player.moving_to_tile.connect(_on_player_moving_to_tile)
	
func _on_player_moving_to_tile(location):
	var tile_location = floor((location - Vector2.ONE * 8) / 16)
	
	if tile_location.y > max_generated_depth - 8:
		generate_new()

func check_duplo_exists(loc: Vector2) -> bool:
	var true_loc = floor(loc/16)
	for delta in DUPLO_LOC_DELTAS:
		if get_cell_atlas_coords(true_loc+delta) == Vector2i(-1, -1):
			return false
	return true

func get_cell(x: int, y: int) -> Vector2i:
	return get_cell_atlas_coords(Vector2i(x, y))

func destroy_tile(x: int, y:int) -> Vector2i:
	var destroyed = get_cell(x, y)
	if destroyed == Static.GOLD_TILE:
		Static.increment_gold(1)
	elif destroyed == Static.GEMS_TILE:
		Static.increment_gems(1)
	erase_cell(Vector2i(x, y))
	return destroyed

# Call if the player is nearing the end of the screen
func generate_new() -> void: # TODO this is the barest of placeholders, there are so many fun things we could do here
	max_generated_depth += 1

	for x_pos in range(-Static.GAME_WIDTH / 2 - 20, Static.GAME_WIDTH / 2 + 20):
		var tile_pos = Vector2i(x_pos, max_generated_depth)

		if x_pos <= -Static.GAME_WIDTH / 2 - 1 || x_pos >= Static.GAME_WIDTH / 2 :
			set_cell(tile_pos, 0, Static.BEDROCK)
		elif max_generated_depth <= 0:
			pass
		elif rng.randi_range(1, 20) == 1:
			set_cell(tile_pos, 0, Static.GOLD_TILE)
		elif rng.randi_range(1, 30) == 1:
			set_cell(tile_pos, 0, Static.GEMS_TILE)
		else:
			set_cell(tile_pos, 0, Static.DIRT_TILE)
		
		if x_pos > -Static.GAME_WIDTH / 2 - 1 && x_pos < Static.GAME_WIDTH / 2 && max_generated_depth > 2:
			FOG_OF_WAR.set_cell(tile_pos, 0, FOG_TILE)

		BACKGROUND.set_cell(tile_pos, 0, BACKGROUND_TILE)
