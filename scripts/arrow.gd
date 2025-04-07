extends StaticBody2D

const PIXELS_PER_SEC = [96, 132] # Travel speed
const LIFETIME = [1.75/3.0, 4.5/5.5*2.0/3.0] # Number of seconds
const DMG = [4, 6]

@onready var sound = get_node("HitSound")

var level = 0

var time_remaining

var already_hit = false # We need this to prevent arrows from hitting 2 almost-overlapping enemies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_remaining = LIFETIME[level]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position + Vector2(1, 0).rotated(global_rotation) * delta * PIXELS_PER_SEC[level]
	time_remaining -= delta
	if time_remaining <= 0:
		destroy()

func hit() -> int: # This is duck typing. Any projectile has a hit() method, which will be called by the enemy it hits. It returns how much damage it deals (it can also do splash damage or something if you want)
	if already_hit: return 0
	visible = false
	get_node("Collisions").disabled = true
	sound.play()
	already_hit = true
	return DMG[level]

func destroy() -> void:
	queue_free()

func _on_hit_sound_finished() -> void:
	destroy()
