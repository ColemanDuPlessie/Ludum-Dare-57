extends Node2D

const APPEAR_DISAPPEAR_TIME = 0.3

const TOWER_UPGRADE_COSTS = {"ARCHER" : [3,],
							"CANNON" : [6,],
							"WIZARD" : [5,]}

var linked_tower

@export var tower_highlight: AnimatedSprite2D
@export var upgrade_button: Area2D

var appearing = false
var disappearing = false

var size = 0.0

func _ready():
	Static.tower_upgrade_menu = self
	scale = Vector2(size, size)
	tower_highlight.scale = Vector2(0, 0)
	tower_highlight.play("default")

	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if appearing:
		size += delta/APPEAR_DISAPPEAR_TIME
		size = clampf(size, 0, 1)
		scale = Vector2(log(size*9+1)/log(10), log(size*9+1)/log(10))
		if size == 1.0:
			tower_highlight.scale = Vector2(1, 1)
			appearing = false
			Static.game_manager.show_range_indicator(global_position, linked_tower.RANGE[linked_tower.level]*16*2)
	elif disappearing:
		size -= delta/APPEAR_DISAPPEAR_TIME
		size = clampf(size, 0, 1)
		scale = Vector2(log(size*9+1)/log(10), log(size*9+1)/log(10))
		if size == 0.0:
			disappearing = false

func open_at(loc: Vector2) -> void:
	if disappearing and size > 0.95: return
	global_position = loc
	size = 0.0
	linked_tower = Static.all_tower_locations[loc]
	if linked_tower.level >= len(TOWER_UPGRADE_COSTS[linked_tower.TYPE]):
		upgrade_button.scale = Vector2(0, 0)
	else:
		upgrade_button.scale = Vector2(1, 1)
		if TOWER_UPGRADE_COSTS[linked_tower.TYPE][linked_tower.level] == 3:
			get_node("UpgradeTower/UpgradeIcon").play("3")
		elif TOWER_UPGRADE_COSTS[linked_tower.TYPE][linked_tower.level] == 5:
			get_node("UpgradeTower/UpgradeIcon").play("5")
		elif TOWER_UPGRADE_COSTS[linked_tower.TYPE][linked_tower.level] == 6:
			get_node("UpgradeTower/UpgradeIcon").play("6")
		
	appear()

func appear() -> void:
	appearing = true
	disappearing = false

func disappear() -> void:
	appearing = false
	disappearing = true
	tower_highlight.scale = Vector2(0, 0)
	Static.game_manager.hide_range_indicator()

func upgrade_tower() -> void:
	linked_tower.upgrade()

func _on_close_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed('mouse_click'):
		disappear()


func _on_upgrade_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (appearing or disappearing) and size < 0.95:
		return
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed('mouse_click'):
			if Static.spend_gold(TOWER_UPGRADE_COSTS[linked_tower.TYPE][linked_tower.level]):
				upgrade_tower()
			disappear()

func _on_sell_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (appearing or disappearing) and size < 0.95:
		return
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed('mouse_click'):
			linked_tower.destroy()
			# TODO maybe get some money back?
			disappear()


func _on_upgrade_tower_mouse_entered() -> void:
	Static.game_manager.show_range_indicator(global_position, linked_tower.RANGE[linked_tower.level+1]*16*2)


func _on_upgrade_tower_mouse_exited() -> void:
	if not disappearing:
		Static.game_manager.show_range_indicator(global_position, linked_tower.RANGE[linked_tower.level]*16*2)
	else:
		Static.game_manager.hide_range_indicator()
