extends Node2D

# @onready var area: Area2D = get_node("ArrowTower")

# func _ready():
	# area.input_event.connect(_on_arrow_tower_input_event)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func build_arrow_tower() -> void:
	print("BUILDING TOWER...")

func _on_arrow_tower_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(event)
	print("Event!")
	if Input.is_action_just_pressed('mouse_click'):
		if true: # TODO check money
			build_arrow_tower()
