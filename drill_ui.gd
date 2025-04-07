extends Control

const MAX_HEIGHT = 35
const DANGER_HEIGHT = 0.1

var flashing = false
const FLASH_LEN = 0.5
var time_to_flash = 0
var flash_on = false

@onready var fill = get_node("LeftComponents/FuelBar/Fill")
@onready var leftComponents: Control = get_node("LeftComponents")

var enabled = false

func _ready() -> void:
	Static.fuel_meter = self

	leftComponents.position = Vector2(-30, 0)

func _process(delta: float) -> void:
	if flashing:
		time_to_flash -= delta
		if time_to_flash <= 0:
			flash_on = not flash_on
			time_to_flash = FLASH_LEN
			if flash_on:
				modulate = Color(1, 0.2, 0.2)
			else:
				modulate = Color(1, 1, 1)
	elif flash_on:
		flash_on = false
		modulate = Color(1, 1, 1)
	if enabled:
		leftComponents.position = Static.fixed_lerp(leftComponents.position, Vector2(0, 0), 4, delta)
	else:
		leftComponents.position = Static.fixed_lerp(leftComponents.position, Vector2(-30, 0), 4, delta)

func set_height(height: float) -> void:
	var int_height = int(MAX_HEIGHT * height)
	if height <= DANGER_HEIGHT:
		flashing = true
	else:
		flashing = false
	fill.scale = Vector2(1, height)

func disable():
	enabled = false

func enable():
	enabled = true
