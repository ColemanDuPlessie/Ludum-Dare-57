extends StaticBody2D

const PIXELS_PER_SEC = 80 # Travel speed
const LIFETIME = 60.0/PIXELS_PER_SEC # Number of seconds
const DMG = 5

var time_remaining

var already_hit = false # We need this to prevent arrows from hitting 2 almost-overlapping enemies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_remaining = LIFETIME

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position + Vector2(1, 0).rotated(global_rotation) * delta * PIXELS_PER_SEC
	time_remaining -= delta
	if time_remaining <= 0:
		destroy()

func hit() -> int: # This is duck typing. Any projectile has a hit() method, which will be called by the enemy it hits. It returns how much damage it deals (it can also do splash damage or something if you want)
	if already_hit: return 0
	destroy()
	already_hit = true
	return DMG

func destroy() -> void:
	queue_free()
