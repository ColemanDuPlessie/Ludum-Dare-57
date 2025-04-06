extends Control

const MAX_HEIGHT = 35

@onready var fill = get_node("LeftComponents/FuelBar/Fill")
@onready var leftComponents: Control = get_node("LeftComponents")

var enabled = false

func _ready() -> void:
	Static.fuel_meter = self

	leftComponents.position = Vector2(-30, 0)

func _process(delta: float) -> void:
	if enabled:
		leftComponents.position = Static.fixed_lerp(leftComponents.position, Vector2(0, 0), 4, delta)
	else:
		leftComponents.position = Static.fixed_lerp(leftComponents.position, Vector2(-30, 0), 4, delta)

func set_height(height: float) -> void:
	var int_height = int(MAX_HEIGHT * height)
	fill.scale = Vector2(1, height)

func disable():
	enabled = false

func enable():
	enabled = true