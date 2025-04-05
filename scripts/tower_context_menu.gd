extends Node2D

const APPEAR_DISAPPEAR_TIME = 0.3

var appearing = false
var disappearing = false

var size = 0.0

func _ready():
	appear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if appearing:
		size += delta/APPEAR_DISAPPEAR_TIME
		size = clampf(size, 0, 1)
		scale = Vector2(log(size*9+1)/log(10), log(size*9+1)/log(10))
		if size == 1.0:
			appearing = false
	elif disappearing:
		size -= delta/APPEAR_DISAPPEAR_TIME
		size = clampf(size, 0, 1)
		scale = Vector2(log(size*9+1)/log(10), log(size*9+1)/log(10))
		if size == 0.0:
			disappearing = false

func appear() -> void:
	appearing = true
	disappearing = false

func disappear() -> void:
	appearing = false
	disappearing = true

func build_arrow_tower() -> void:
	print("BUILDING TOWER...")

func _on_arrow_tower_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if appearing or disappearing:
		return
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed('mouse_click'):
			if true: # TODO check money
				build_arrow_tower()
