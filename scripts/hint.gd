extends Node2D

@export var hint: String = "none"

var size = 0

var delay = 1.0

func _ready():
	scale = Vector2(0, 0)

func _process(delta: float) -> void:

	if Static.currently_displayed_hint == hint:
		delay -= delta
		if hint == "move": delay = 0

		if delay > 0:
			return

		size += delta * 3
	else:
		size -= delta * 3

	size = clampf(size, 0, 1)

	if Static.currently_displayed_hint == hint:
		scale = Vector2(Static.easing(size), Static.easing(size))
	else:
		scale = Vector2(Static.easing(size), Static.easing(size))
	
