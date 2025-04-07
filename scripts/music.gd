extends Node

@onready var combat_player: AudioStreamPlayer = get_node("CombatPlayer")
@onready var building_player: AudioStreamPlayer = get_node("BuildingPlayer")

func _ready() -> void:
	combat_player.volume_linear = 0
	building_player.volume_linear = 0.4

	combat_player.play()
	building_player.play()

func _process(delta: float) -> void:
	if Static.game_manager.state == "building":
		building_player.volume_linear = clamp(building_player.volume_linear + delta / 3.0, 0, 0.4)
		combat_player.volume_linear = clamp(combat_player.volume_linear - delta / 3.0, 0, 0.4)

	if Static.game_manager.state == "combat":
		combat_player.volume_linear = clamp(combat_player.volume_linear + delta / 3.0, 0, 0.4)
		building_player.volume_linear = clamp(building_player.volume_linear - delta / 3.0, 0, 0.4)
