extends Node

const GAME_WIDTH = 15 * 2

const DIRT_TILE = Vector2i(16, 1)
const GOLD_TILE = Vector2i(17, 1)
const GEMS_TILE = Vector2i(16, 2)
const BEDROCK = Vector2i(16, 5)
const STONE = Vector2i(16, 3)
const STONE_GOLD = Vector2i(17, 3)
const STONE_GEMS = Vector2i(16, 4)
const HELL_STONE = Vector2i(16, 7)
const HELL_STONE_GOLD = Vector2i(17, 7)
const HELL_STONE_GEMS = Vector2i(16, 8)
const JADE = Vector2i(16, 9)
const JADE_GOLD = Vector2i(17, 9)
const JADE_GEMS = Vector2i(16, 10)

const FUEL_COSTS = {
	DIRT_TILE : [1, 1, 1, 1, 1],
	GOLD_TILE : [4, 2, 2, 2, 2],
	GEMS_TILE : [4, 4, 2, 2, 2],
	BEDROCK : [999999999, 999999999, 999999999, 999999999, 999999999],
	STONE : [999999999, 6, 4, 4, 2],
	STONE_GOLD : [999999999, 8, 4, 4, 2],
	STONE_GEMS : [999999999, 10, 6, 6, 4],
	HELL_STONE : [999999999, 999999999, 999999999, 14, 6],
	HELL_STONE_GOLD : [999999999, 999999999, 999999999, 16, 8],
	HELL_STONE_GEMS : [999999999, 999999999, 999999999, 18, 8],
	JADE : [999999999, 999999999, 999999999, 14, 6],
	JADE_GOLD : [999999999, 999999999, 999999999, 32, 16],
	JADE_GEMS : [999999999, 999999999, 999999999, 36, 16],
}

var all_tower_locations = {} # An dictionary of the form Vector2:tower.
var all_enemies = [] # A list of all active enemies TODO garbage collect dead enemies

var current_gold = 0
var current_gems = 0

const INITIAL_MAX_FUEL = 35
var MAX_FUEL = 35
var PLAYER_GUN_LEVEL = 0 # 4 levels: max is level 3
var PLAYER_RADAR_LEVEL = 0 # 5 levels: max is level 4
var PLAYER_DRILL_LEVEL = 0 # 5 levels: max is level 4

var MAX_REVEAL_RANGE = 5 # The player can see sqrt(MAX_REVEAL_RANGE) units away in any direction. We can sell upgrades for this.
var RADAR_POWERS = [5, 10, 20, 28, 40]

var gold_counter
var gems_counter
var UI
var shop
var fuel_meter
var tower_menu
var tower_upgrade_menu

var health = 3
var game_manager = null
var game_in_progress = false

var camera = null

var round_number = 0
var deepest = 0

var currently_displayed_hint = "move"

func _change_gold(new:int) -> void:
	current_gold += new
	gold_counter.text = str(current_gold)

func _change_gems(new:int) -> void:
	current_gems += new
	gems_counter.text = str(current_gems)

func increment_gold(amt: int) -> void:
	_change_gold(amt)
	
# Returns true and deducts gold if we can afford it. Otherwise returns false.
func spend_gold(amt: int) -> bool:
	if current_gold >= amt:
		_change_gold(-amt)
		game_manager.buy.play()
		return true
	game_manager.buy_fail.play()
	gold_counter.get_parent().gold_flash = 0.5
	return false
	
func increment_gems(amt: int) -> void:
	_change_gems(amt)

# Returns true and deducts gems if we can afford it. Otherwise returns false.
func spend_gems(amt: int) -> bool:
	if current_gems >= amt:
		_change_gems(-amt)
		game_manager.buy.play()
		return true
	game_manager.buy_fail.play()
	gems_counter.get_parent().gem_flash = 0.5
	return false

# Returns true and deducts resources if we can afford all aspects. Otherwise returns false.
func spend_gold_and_gems(gold_amt: int, gems_amt: int) -> bool:
	if current_gold >= gold_amt and current_gems >= gems_amt:
		_change_gold(-gold_amt)
		_change_gems(-gems_amt)
		game_manager.buy.play()
		return true
	game_manager.buy_fail.play()
	gold_counter.get_parent().gold_flash = 0.5
	gems_counter.get_parent().gem_flash = 0.5
	return false

func easing(value: float) -> float:
	return 1 - pow(1 - value, 3)

func fixed_lerp(a, b, decay, delta):
	return b + (a - b) * exp(-decay * delta)
