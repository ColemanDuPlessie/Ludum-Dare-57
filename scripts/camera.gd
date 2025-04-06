extends Camera2D

@onready var game_manager = get_node("../GameManager")

var smoothed_position = Vector2.ZERO

var shake_timer = 0
var shake_direction = Vector2.RIGHT
var shake_position
var shake_intensity = 0

func _ready() -> void:
	smoothed_position = global_position

	Static.camera = self

func _process(delta: float) -> void:
	shake_timer -= delta
	
	if shake_timer <= 0:
		shake_timer = randf_range(0.015, 0.03)

		shake_direction = Vector2.RIGHT.rotated(randf_range(0, PI * 2))

	shake_position = shake_direction * pow(shake_intensity * 2, 1.5)

	shake_intensity = Static.fixed_lerp(shake_intensity, 0, 14, delta)

	if Static.game_in_progress:
		var player = game_manager.current_player

		if player == null:
			return

		smoothed_position = Static.fixed_lerp(smoothed_position, player.global_position, 8, delta)
	else:
		smoothed_position = Static.fixed_lerp(smoothed_position, Vector2(0, -50), 2, delta)

	global_position = smoothed_position + shake_position

func shake(intensity):
	shake_intensity = max(intensity, shake_intensity)