extends StaticBody2D

const PIXELS_PER_SEC = 80 # Travel speed
const LIFETIME = 60.0/PIXELS_PER_SEC # Number of seconds
const DMG = 5

var time_remaining

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_remaining = LIFETIME

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position + Vector2(1, 0).rotated(global_rotation) * delta * PIXELS_PER_SEC
	time_remaining -= delta
	if time_remaining <= 0:
		destroy()

func destroy() -> void:
	queue_free()
