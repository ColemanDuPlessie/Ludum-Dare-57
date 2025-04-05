extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func build_arrow_tower() -> void:
	pass

func _on_arrow_tower_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.button == MOUSE_BUTTON_LEFT and event.pressed:
		if true: # TODO check money
			build_arrow_tower()
