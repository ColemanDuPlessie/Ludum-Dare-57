extends Node

const GAME_WIDTH = 10 * 2

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

var all_tower_locations = {} # An dictionary of the form Vector2:tower.
var all_enemies = [] # A list of all active enemies TODO garbage collect dead enemies

var current_gold = 0
var current_gems = 0

var MAX_FUEL = 50
var PLAYER_GUN_LEVEL = 0 # 4 levels: max is level 3
var PLAYER_RADAR_LEVEL = 0 # 5 levels: max is level 4

var MAX_REVEAL_RANGE = 5 # The player can see sqrt(MAX_REVEAL_RANGE) units away in any direction. We can sell upgrades for this.
var RADAR_POWERS = [5, 10, 20, 28, 40]

var gold_counter
var gems_counter
var UI
var shop
var fuel_meter
var tower_menu

var in_shop = false

var health = 3
var game_manager = null

func show_shop():
	if !shop.is_inside_tree():
		UI.add_child(shop)
		in_shop = true

func hide_shop():
	if shop.is_inside_tree():
		UI.remove_child(shop)
		in_shop = false

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
		return true
	return false
	
func increment_gems(amt: int) -> void:
	_change_gems(amt)

# Returns true and deducts gems if we can afford it. Otherwise returns false.
func spend_gems(amt: int) -> bool:
	if current_gems >= amt:
		_change_gems(-amt)
		return true
	return false

# Returns true and deducts resources if we can afford all aspects. Otherwise returns false.
func spend_gold_and_gems(gold_amt: int, gems_amt: int) -> bool:
	if current_gold >= gold_amt and current_gems >= gems_amt:
		_change_gold(-gold_amt)
		_change_gems(-gems_amt)
		return true
	return false
