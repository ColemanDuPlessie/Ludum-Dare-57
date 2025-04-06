extends TileMapLayer

@export var FOG_OF_WAR: TileMapLayer
const FOG_TILE = Vector2i(19, 1)
@export var BACKGROUND: TileMapLayer
const BACKGROUND_TILE = Vector2i(19, 3)

const DUPLO_LOC_DELTAS = [Vector2(0, 0), Vector2(-1, 0), Vector2(0, -1), Vector2(-1, -1)]

const STONE_START = 8
const DIRT_END = 20
const FIRE_START = 30
const STONE_END = 42

var rng = RandomNumberGenerator.new()
var max_generated_depth = -10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()

func _on_drill_spawned(player):
	player.moving_to_tile.connect(_on_player_moving_to_tile)
	
func _on_player_moving_to_tile(location):
	var tile_location = floor((location - Vector2.ONE * 8) / 16)
	
	if tile_location.y > max_generated_depth - 8:
		generate_new()

func generate_start():
	rng = RandomNumberGenerator.new()
	max_generated_depth = -10

	while max_generated_depth < 7:
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
		$gold.play()
		Static.increment_gold(1)
	elif destroyed == Static.GEMS_TILE:
		$gem.play()
		Static.increment_gems(1)
	elif destroyed == Static.DIRT_TILE:
		$dirt.play()
	elif destroyed == Static.STONE_GOLD:
		$stone.play()
		$gold.play()
		Static.increment_gold(2)
	elif destroyed == Static.STONE_GEMS:
		$stone.play()
		$gem.play()
		Static.increment_gems(2)
	elif destroyed == Static.STONE:
		$stone.play()
	elif destroyed == Static.HELL_STONE_GOLD:
		$stone.play()
		$gold.play()
		Static.increment_gold(3)
	elif destroyed == Static.HELL_STONE_GEMS:
		$stone.play()
		$gem.play()
		Static.increment_gems(3)
	elif destroyed == Static.HELL_STONE:
		$stone.play()
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
		else:
			var type = "DIRT"
			if max_generated_depth > STONE_END:
				type = "FIRE"
			elif max_generated_depth > FIRE_START:
				var fire_odds = float(max_generated_depth-FIRE_START)/(STONE_END-FIRE_START)
				fire_odds += float(2*abs(x_pos))/Static.GAME_WIDTH * 0.2 - 0.1
				if rng.randf() < fire_odds:
					type = "FIRE"
				else:
					type = "STONE"
			elif max_generated_depth > DIRT_END:
				type = "STONE"
			elif max_generated_depth > STONE_START:
				var stone_odds = float(max_generated_depth-STONE_START)/(DIRT_END-STONE_START)
				stone_odds += float(2*abs(x_pos))/Static.GAME_WIDTH * 0.3 - 0.15
				if rng.randf() < stone_odds:
					type = "STONE"
			if type == "DIRT":
				if rng.randi_range(1, 20) == 1:
					set_cell(tile_pos, 0, Static.GOLD_TILE)
				elif rng.randi_range(1, 30) == 1:
					set_cell(tile_pos, 0, Static.GEMS_TILE)
				else:
					set_cell(tile_pos, 0, Static.DIRT_TILE)
			elif type == "STONE":
				if rng.randi_range(1, 20) == 1:
					set_cell(tile_pos, 0, Static.STONE_GOLD)
				elif rng.randi_range(1, 30) == 1:
					set_cell(tile_pos, 0, Static.STONE_GEMS)
				else:
					set_cell(tile_pos, 0, Static.STONE)
			else:
				if rng.randi_range(1, 20) == 1:
					set_cell(tile_pos, 0, Static.HELL_STONE_GOLD)
				elif rng.randi_range(1, 30) == 1:
					set_cell(tile_pos, 0, Static.HELL_STONE_GEMS)
				else:
					set_cell(tile_pos, 0, Static.HELL_STONE)
		
		if x_pos > -Static.GAME_WIDTH / 2 - 1 && x_pos < Static.GAME_WIDTH / 2 && max_generated_depth > 2:
			FOG_OF_WAR.set_cell(tile_pos, 0, FOG_TILE)

		BACKGROUND.set_cell(tile_pos, 0, BACKGROUND_TILE)
