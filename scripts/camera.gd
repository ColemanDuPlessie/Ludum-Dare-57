extends Camera2D


@onready var game_manager = get_node("../GameManager")


func _process(delta: float) -> void:
	if Static.game_in_progress:
		var player = game_manager.current_player

		if player == null:
			return

		global_position = Static.fixed_lerp(global_position, player.global_position, 8, delta)
	else:
		global_position = Static.fixed_lerp(global_position, Vector2(0, -50), 2, delta)