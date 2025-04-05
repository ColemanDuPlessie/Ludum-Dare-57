extends TileMapLayer

@export var FOG_OF_WAR: TileMapLayer
const FOG_TILE = Vector2i(19, 1)
@export var BACKGROUND: TileMapLayer
const BACKGROUND_TILE = Vector2i(19, 3)

const GAME_WIDTH = 18

const DIRT_TILE = Vector2i(16, 1)
const GOLD_TILE = Vector2i(17, 1)
const GEMS_TILE = Vector2i(16, 2)
const OBSIDIAN_TILE = Vector2i(16, 3)
const BEDROCK = Vector2i(16, 5)

const FUEL_COSTS = {
	DIRT_TILE : 1,
	GOLD_TILE : 1,
	GEMS_TILE : 2,
	OBSIDIAN_TILE : 10,
	BEDROCK : 999999999,
}

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

	print(tile_location.y)
	print(max_generated_depth)

	if tile_location.y > max_generated_depth - 8:
		generate_new()

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
	for x_pos in range(-GAME_WIDTH/2 - 20, GAME_WIDTH/2 + 20 + 1):
		var tile_pos = Vector2i(x_pos, max_generated_depth)

		if x_pos <= -GAME_WIDTH / 2 - 1 || x_pos >= GAME_WIDTH / 2 + 1:
			set_cell(tile_pos, 0, BEDROCK)
		elif max_generated_depth <= 0:
			pass
		elif rng.randi_range(1, 20) == 1:
			set_cell(tile_pos, 0, GOLD_TILE)
		elif rng.randi_range(1, 40) == 1:
			set_cell(tile_pos, 0, GEMS_TILE)
		else:
			set_cell(tile_pos, 0, DIRT_TILE)
		
		if x_pos > -GAME_WIDTH / 2 - 1 && x_pos < GAME_WIDTH / 2 + 1 && max_generated_depth > 2:
			FOG_OF_WAR.set_cell(tile_pos, 0, FOG_TILE)

		# if x_pos > -GAME_WIDTH / 2 - 1 && x_pos < GAME_WIDTH / 2 + 1 && max_generated_depth > 0:
		BACKGROUND.set_cell(tile_pos, 0, BACKGROUND_TILE)
