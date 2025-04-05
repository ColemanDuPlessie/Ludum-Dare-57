extends Camera2D


@onready var game_manager = get_node("../GameManager")


func _process(delta: float) -> void:
	var player = game_manager.current_player

	global_position = player.global_position
