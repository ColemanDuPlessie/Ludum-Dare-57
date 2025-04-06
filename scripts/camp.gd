extends Node2D

var size = 0
var appearing = false

@export var uiOrigin: Node2D

func _ready():
	uiOrigin.scale = Vector2(1, 0)

func _player_entered_area(_body):
	appearing = true

func _player_exited_area(_body):
	appearing = false

func _process(delta: float) -> void:
	if appearing:
		size += delta * 3
	else:
		size -= delta * 3

	size = clampf(size, 0, 1)

	if appearing:
		uiOrigin.scale = Vector2(Static.easing(size), Static.easing(size))
	else:
		uiOrigin.scale = Vector2(Static.easing(size), Static.easing(size))

func start_round():
	Static.game_manager.begin_combat()