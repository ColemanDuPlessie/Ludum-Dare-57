extends Control

var enabled = false

func _ready() -> void:
	Static.gold_counter = get_node("GoldCounter")
	Static.gems_counter = get_node("GemCounter")

	position = Vector2(-100, 0)

func _process(delta: float) -> void:
	if enabled:
		position = Static.fixed_lerp(position, Vector2(0, 0), 4, delta)
	else:
		position = Static.fixed_lerp(position, Vector2(-100, 0), 4, delta)

func disable():
	enabled = false

func enable():
	enabled = true
