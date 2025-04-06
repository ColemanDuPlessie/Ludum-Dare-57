extends Node2D

const APPEAR_DISAPPEAR_TIME = 0.3

const TOWER_UPGRADE_COSTS = {}

var linked_tower

@export var tower_highlight: AnimatedSprite2D

var appearing = false
var disappearing = false

var size = 0.0

func _ready():
	Static.tower_menu = self
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
	elif disappearing:
		size -= delta/APPEAR_DISAPPEAR_TIME
		size = clampf(size, 0, 1)
		scale = Vector2(log(size*9+1)/log(10), log(size*9+1)/log(10))
		if size == 0.0:
			disappearing = false

func open_at(loc: Vector2) -> void:
	global_position = loc
	size = 0.0
	linked_tower = Static.all_tower_locations[loc]
	print(linked_tower.name)
	appear()

func appear() -> void:
	appearing = true
	disappearing = false

func disappear() -> void:
	appearing = false
	disappearing = true
	tower_highlight.scale = Vector2(0, 0)

func upgrade_tower() -> void:
	pass

func _on_close_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed('mouse_click'):
		disappear()


func _on_upgrade_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if appearing or disappearing:
		return
	pass

func _on_sell_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
