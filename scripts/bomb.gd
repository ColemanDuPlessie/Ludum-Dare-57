extends StaticBody2D

const DMG = [6, 9]
const FLIGHT_TIME = [0.4, 0.45]
const PIXEL_HEIGHT_PEAK = [35, 45]
const PIXEL_AOE_RADIUS = 12
const GRAPHICS_LINGER_DURATION = 0.5

var time_remaining

var destination
var start_pos

var level = 0

var exploded = false

@onready var sprite = get_node("BombSprite")
@onready var sound = get_node("HitSound")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_remaining = FLIGHT_TIME[level]
	sprite.play("Flying")

func move() -> void:
	var fraction_elapsed =  (1.0 - (time_remaining/FLIGHT_TIME[level]))
	global_position = start_pos + (destination - start_pos) * fraction_elapsed + Vector2(0, PIXEL_HEIGHT_PEAK[level] * ((2*fraction_elapsed-1)**2 - 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_remaining -= delta
	if time_remaining <= 0:
		if not exploded:
			time_remaining = 0.0
			move()
			explode()
		if time_remaining <= -GRAPHICS_LINGER_DURATION:
			destroy()
	else:
		move()

func explode() -> void:
	sprite.play("Exploding")
	sound.play()
	exploded = true
	for enemy in Static.all_enemies:
		if global_position.distance_to(enemy.global_position) <= PIXEL_AOE_RADIUS:
			enemy.take_damage(DMG[level])

func destroy() -> void:
	queue_free()
