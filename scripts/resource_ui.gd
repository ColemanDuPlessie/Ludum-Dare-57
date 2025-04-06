extends Control

@onready var health_container: Control = get_node("Health")

var heart_icon = ResourceLoader.load("res://art/heart.tres")
var heart_empty_icon = ResourceLoader.load("res://art/heart_empty.tres")

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

	for index in range(health_container.get_child_count()):
		var icon: TextureRect = health_container.get_child(index)

		if Static.health >= index + 1:
			icon.texture = heart_icon
		else:
			icon.texture = heart_empty_icon

func disable():
	enabled = false

func enable():
	enabled = true
