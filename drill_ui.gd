extends Control

const MAX_HEIGHT = 35

@onready var fill = get_node("FuelBar/Fill")

func _ready() -> void:
	Static.fuel_meter = self

func set_height(height: float) -> void:
	var int_height = int(MAX_HEIGHT * height)
	fill.scale = Vector2(1, height)
