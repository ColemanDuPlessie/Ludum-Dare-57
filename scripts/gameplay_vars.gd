extends Node2D

var current_gold = 0
var current_gems = 0
@onready var gold_counter = get_node("UIOverlay/GoldCounter")
@onready var gems_counter = get_node("UIOverlay/GemCounter")
@onready var UI = get_node("UIOverlay")
@onready var shop = get_node("UIOverlay/Shop")

func show_shop():
	if !shop.is_inside_tree():
		UI.add_child(shop)

func hide_shop():
	if shop.is_inside_tree():
		UI.remove_child(shop)

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	increment_gold(5) # TODO this is temporary
	increment_gems(2)
	hide_shop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
