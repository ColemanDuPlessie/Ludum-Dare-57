extends Node2D

const APPEAR_DISAPPEAR_TIME = 0.3

var archer_scene: PackedScene = ResourceLoader.load("res://scenes/archer_tower.tscn")

@export var tower_highlight: AnimatedSprite2D

var appearing = false
var disappearing = false

var size = 0.0

func _ready():
	Static.tower_menu = self
	scale = Vector2(size, size)
	tower_highlight.scale = Vector2(0, 0)
	tower_highlight.play("default")

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
	appear()

func appear() -> void:
	appearing = true
	disappearing = false

func disappear() -> void:
	appearing = false
	disappearing = true
	tower_highlight.scale = Vector2(0, 0)

func build_arrow_tower() -> void:
	print("BUILDING TOWER...")
	var tower: Node2D = archer_scene.instantiate()
	add_sibling(tower)
	tower.global_position = global_position
	Static.all_tower_locations[global_position] = tower

func _on_arrow_tower_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if appearing or disappearing:
		return
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed('mouse_click'):
			if Static.spend_gold(5):
				build_arrow_tower()
			disappear()


func _on_close_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed('mouse_click'):
		disappear()
