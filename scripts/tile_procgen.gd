extends TileMapLayer

const GAME_WIDTH = 18
const HEIGHT_OFFSET = 3

const DIRT_TILE = Vector2i(1, 1)
const GOLD_TILE = Vector2i(2, 0)
const GEMS_TILE = Vector2i(3, 1)
const OBSIDIAN_TILE = Vector2i(0, 1)

var rng = RandomNumberGenerator.new();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	for i in range(20):
		generate_new()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var max_generated_depth = 7 # The game starts with 7 tiles of ground TODO procgen these in _ready()

# Call if the player is nearing the end of the screen
func generate_new() -> void: # TODO this is the barest of placeholders, there are so many fun things we could do here
	max_generated_depth += 1
	for x_pos in range(-GAME_WIDTH/2, GAME_WIDTH/2):
		var tile_pos = Vector2i(x_pos, max_generated_depth-HEIGHT_OFFSET)
		if rng.randi_range(1, 20) == 1:
			set_cell(tile_pos, 0, GOLD_TILE)
		elif rng.randi_range(1, 40) == 1:
			set_cell(tile_pos, 0, GEMS_TILE)
		else:
			set_cell(tile_pos, 0, DIRT_TILE)
	pass
