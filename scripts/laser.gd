extends StaticBody2D

var PIXELS_PER_SEC = [40, 45, 50, 60] # Travel speed
var LIFETIME = [0.75, 0.8, 0.85, 0.9] # Number of seconds
var DMG = [1.6, 2.0, 2.6, 3.4]

var time_remaining

var already_hit = false # We need this to prevent arrows from hitting 2 almost-overlapping enemies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_remaining = LIFETIME[Static.PLAYER_GUN_LEVEL]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position + Vector2(1, 0).rotated(global_rotation) * delta * PIXELS_PER_SEC[Static.PLAYER_GUN_LEVEL]
	time_remaining -= delta
	if time_remaining <= 0:
		destroy()

func hit() -> int: # This is duck typing. Any projectile has a hit() method, which will be called by the enemy it hits. It returns how much damage it deals (it can also do splash damage or something if you want)
	if already_hit: return 0
	destroy()
	already_hit = true
	return DMG[Static.PLAYER_GUN_LEVEL]

func destroy() -> void:
	queue_free()
